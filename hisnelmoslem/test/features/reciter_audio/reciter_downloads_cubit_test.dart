import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/data/audio_file_store.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/data/http_audio_downloader.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/data/reciter_audio_repo.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/reciter.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/controller/reciter_downloads_cubit.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/controller/reciter_downloads_state.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

/// Writes 10 bytes per file; can fail or wait for a gate, like a slow or broken network.
class FakeDownloader implements AudioDownloader {
  final Set<String> failing = {};
  final Map<String, Completer<void>> gates = {};
  final List<String> started = [];

  @override
  Future<int?> contentLength(String url) async => 10;

  @override
  Future<int> download({
    required String url,
    required File target,
    void Function(int received, int? total)? onProgress,
    DownloadCancelToken? cancel,
  }) async {
    started.add(url);
    await gates[url]?.future;
    if (cancel?.isCancelled ?? false) throw const DownloadCancelled();
    if (failing.contains(url)) throw DownloadFailed(url);
    await target.parent.create(recursive: true);
    await target.writeAsBytes(List.filled(10, 1));
    onProgress?.call(10, 10);
    return 10;
  }
}

DbContent zikr(int id, int titleId, Map<String, List<String>> urls, {bool ok = true}) => DbContent(
  id: id,
  content: 'z$id',
  titleId: titleId,
  order: id,
  count: 1,
  fadl: '',
  source: '',
  search: '',
  hokm: '',
  audio: '',
  hasAudio: false,
  audioUrls: urls,
  audioRemoteOk: ok,
);

String url(String name) => 'https://cdn.binwahaf.com/uploads/2025/12/$name.mp3';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => Directory.systemTemp.createTempSync('downloads_cubit_test').path,
    );
    await GetStorage.init('downloads_cubit_test');
  });

  final contents = [
    zikr(1, 10, {
      'hamad_alduraihem': [url('a')],
    }),
    zikr(2, 10, {
      'hamad_alduraihem': [url('b')],
    }),
    zikr(3, 11, {
      'hamad_alduraihem': [url('a')],
    }), // shares the lesson of zikr 1
    zikr(4, 11, {
      'hamad_alduraihem': [url('c')],
    }, ok: false), // not allowed remotely
    zikr(5, 12, {
      'hamad_alduraihem': [url('d'), url('e')],
    }), // spans two lessons
    zikr(6, 12, {}), // no recording
  ];

  late Directory root;
  late FakeDownloader downloader;
  late AudioFileStore store;
  late ReciterAudioRepo repo;
  late ReciterDownloadsCubit cubit;
  const hamad = Reciter.hamadAlduraihem;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('downloads_cubit_root');
    downloader = FakeDownloader();
    store = AudioFileStore(() async => root);
    repo = ReciterAudioRepo(GetStorage('downloads_cubit_test'));
    await repo.clearJob();
    cubit = ReciterDownloadsCubit(
      downloader: downloader,
      store: store,
      repo: repo,
      loadContents: ({int? titleId}) async =>
          titleId == null ? contents : contents.where((c) => c.titleId == titleId).toList(),
      parallel: 2,
    );
  });

  tearDown(() async {
    await cubit.close();
    if (await root.exists()) await root.delete(recursive: true);
  });

  group('plan', () {
    test(
      'lists each lesson once, skips the zikrs that are not remote-ok and adds the sizes',
      () async {
        final plan = await cubit.buildPlan(hamad);

        expect(plan.pendingUrls, [url('a'), url('b'), url('d'), url('e')]);
        expect(plan.alreadyDownloaded, 0);
        expect(plan.pendingBytes, 40);
        expect(plan.unknownSizes, 0);
      },
    );

    test('a title only needs its own files', () async {
      final plan = await cubit.buildPlan(hamad, titleId: 12);
      expect(plan.pendingUrls, [url('d'), url('e')]);
    });

    test('files that are already on the phone are not pending', () async {
      final file = await store.fileOf(hamad, url('a'));
      await file.parent.create(recursive: true);
      await file.writeAsBytes([1, 2, 3]);

      final plan = await cubit.buildPlan(hamad);

      expect(plan.pendingUrls, [url('b'), url('d'), url('e')]);
      expect(plan.alreadyDownloaded, 1);
      expect(plan.totalFiles, 4);
    });

    test('a reciter without recordings gives an empty plan', () async {
      final plan = await cubit.buildPlan(Reciter.rashidAlhulaibah);
      expect(plan.isEmpty, isTrue);
    });
  });

  group('per title', () {
    test('statuses cover every title that has recordings, with what is on the phone', () async {
      final file = await store.fileOf(hamad, url('a'));
      await file.parent.create(recursive: true);
      await file.writeAsBytes(List.filled(7, 1));

      final statuses = await cubit.titleStatuses(hamad);

      expect(statuses.keys, unorderedEquals([10, 11, 12]));
      expect(statuses[10]!.totalFiles, 2);
      expect(statuses[10]!.downloadedFiles, 1);
      expect(statuses[10]!.downloadedBytes, 7);
      expect(statuses[11]!.totalFiles, 1); // zikr 4 is not remote-ok
      expect(statuses[12]!.downloadedFiles, 0);
      expect(statuses[11]!.isComplete, isTrue); // shares lesson a with title 10
    });

    test('deleting a title removes its files and its unfinished parts', () async {
      await cubit.start(await cubit.buildPlan(hamad));
      final part = File('${(await store.fileOf(hamad, url('d'))).path}.part');
      await part.writeAsBytes([1]);

      await cubit.deleteTitle(hamad, 12);

      expect(await store.existingPath(hamad, url('d')), isNull);
      expect(await store.existingPath(hamad, url('e')), isNull);
      expect(part.existsSync(), isFalse);
      // Another title's own file stays.
      expect(await store.existingPath(hamad, url('b')), isNotNull);
    });
  });

  group('running a job', () {
    test('downloads everything, ends completed and forgets the job', () async {
      final plan = await cubit.buildPlan(hamad);
      await cubit.start(plan);

      expect(cubit.state.status, DownloadStatus.completed);
      expect(cubit.state.doneFiles, 4);
      expect(cubit.state.totalFiles, 4);
      expect(cubit.state.failedUrls, isEmpty);
      expect(await store.downloadedFiles(hamad), hasLength(4));
      expect(repo.loadJob(), isNull);
    });

    test('a failed file is listed and a resume retries only that one', () async {
      downloader.failing.add(url('b'));
      await cubit.start(await cubit.buildPlan(hamad));

      expect(cubit.state.status, DownloadStatus.completed);
      expect(cubit.state.failedUrls, [url('b')]);
      expect(cubit.state.doneFiles, 3);

      downloader
        ..failing.clear()
        ..started.clear();
      await cubit.resume();

      expect(downloader.started, [url('b')]);
      expect(cubit.state.failedUrls, isEmpty);
      expect(cubit.state.doneFiles, 4);
    });

    test('pause keeps the job and the finished files, resume finishes the rest', () async {
      downloader.gates[url('b')] = Completer<void>();
      final plan = await cubit.buildPlan(hamad);
      final run = cubit.start(plan);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(cubit.state.isRunning, isTrue);

      cubit.pause();
      downloader.gates[url('b')]!.complete();
      await run;

      expect(cubit.state.status, DownloadStatus.paused);
      expect(repo.loadJob()?.reciter, hamad);
      final partial = (await store.downloadedFiles(hamad)).length;
      expect(partial, lessThan(4));

      downloader.started.clear();
      await cubit.resume();

      expect(cubit.state.status, DownloadStatus.completed);
      expect(await store.downloadedFiles(hamad), hasLength(4));
      // Nothing that was finished is fetched again.
      expect(downloader.started.length, 4 - partial);
    });

    test('cancel forgets the job but leaves the files', () async {
      downloader.gates[url('b')] = Completer<void>();
      final run = cubit.start(await cubit.buildPlan(hamad));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await cubit.cancel();
      downloader.gates[url('b')]!.complete();
      await run;

      expect(cubit.state.status, DownloadStatus.idle);
      expect(repo.loadJob(), isNull);
    });

    test('an interrupted job shows as paused after restore', () async {
      await repo.saveJob(Reciter.rashidAlhulaibah, 12);

      cubit.restore();

      expect(cubit.state.status, DownloadStatus.paused);
      expect(cubit.state.reciter, Reciter.rashidAlhulaibah);
      expect(cubit.state.titleId, 12);
    });

    test('a second start while running is ignored', () async {
      downloader.gates[url('a')] = Completer<void>();
      final plan = await cubit.buildPlan(hamad);
      final run = cubit.start(plan);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      await cubit.start(plan);
      downloader.gates[url('a')]!.complete();
      await run;

      expect(downloader.started.where((u) => u == url('a')), hasLength(1));
    });
  });
}
