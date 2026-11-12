import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/data/audio_file_store.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/data/http_audio_downloader.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/data/reciter_audio_repo.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/byte_format.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/download_plan.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/reciter.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/components/download_confirm_dialog.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/components/reciter_audio_sheet.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/controller/reciter_downloads_cubit.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

class _NoNetwork implements AudioDownloader {
  @override
  Future<int?> contentLength(String url) async => 1024 * 1024;

  @override
  Future<int> download({
    required String url,
    required File target,
    void Function(int received, int? total)? onProgress,
    DownloadCancelToken? cancel,
  }) async => throw const DownloadFailed('offline');
}

Widget app(Widget child) => MaterialApp(
  localizationsDelegates: S.localizationsDelegates,
  supportedLocales: S.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('formatBytes', () {
    test('short readable sizes', () {
      expect(formatBytes(512), '512 B');
      expect(formatBytes(2048), '2 KB');
      expect(formatBytes(3 * 1024 * 1024 + 400 * 1024), '3.4 MB');
      expect(formatBytes(62 * 1024 * 1024), '62 MB');
    });
  });

  testWidgets('the confirm dialog shows the count and the size, and returns the answer', (
    tester,
  ) async {
    const plan = DownloadPlan(
      reciter: Reciter.hamadAlduraihem,
      titleId: null,
      pendingUrls: ['a', 'b', 'c'],
      alreadyDownloaded: 0,
      pendingBytes: 5 * 1024 * 1024,
    );
    bool? answer;
    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async => answer = await DownloadConfirmDialog.show(context, plan: plan),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Hamad Al-Duraihem'), findsOneWidget);
    expect(find.text('3 files, about 5.0 MB. This may use mobile data.'), findsOneWidget);

    await tester.tap(find.text('Download all'));
    await tester.pumpAndSettle();
    expect(answer, isTrue);
  });

  group('ReciterAudioSheet', () {
    late Directory root;
    late ReciterAudioRepo repo;

    setUpAll(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (call) async => Directory.systemTemp.createTempSync('reciter_ui_test').path,
      );
      await GetStorage.init('reciter_ui_test');
    });

    setUp(() async {
      root = await Directory.systemTemp.createTemp('reciter_ui_root');
      repo = ReciterAudioRepo(GetStorage('reciter_ui_test'));
      await repo.setReciter(Reciter.hamadAlduraihem);
      await repo.setAllowStream(true);

      final store = AudioFileStore(() async => root);
      final cubit = ReciterDownloadsCubit(
        downloader: _NoNetwork(),
        store: store,
        repo: repo,
        loadContents: ({int? titleId}) async => [
          const DbContent(
            id: 1,
            content: 'x',
            titleId: 1,
            order: 1,
            count: 1,
            fadl: '',
            source: '',
            search: '',
            hokm: '',
            audio: '',
            hasAudio: false,
            audioRemoteOk: true,
            audioUrls: {
              'hamad_alduraihem': ['https://cdn.binwahaf.com/uploads/2025/12/0001.mp3'],
              'rashid_alhulaibah': ['https://cdn.binwahaf.com/uploads/2025/12/0001-1.mp3'],
            },
          ),
        ],
      );
      sl
        ..registerSingleton<ReciterAudioRepo>(repo)
        ..registerSingleton<AudioFileStore>(store)
        ..registerSingleton<ReciterDownloadsCubit>(cubit);
    });

    tearDown(() async {
      await GetIt.instance.reset();
      if (root.existsSync()) root.deleteSync(recursive: true);
    });

    testWidgets('lists the reciters, saves the choice and the streaming switch', (tester) async {
      tester.view.physicalSize = const Size(360 * 3, 900 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.runAsync(() async {
        await tester.pumpWidget(app(const ReciterAudioSheet()));
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();

      expect(find.text('Reciter and downloads'), findsOneWidget);
      expect(find.text('Hamad Al-Duraihem'), findsOneWidget);
      expect(find.text('Rashid Al-Hulaibah'), findsOneWidget);
      expect(find.textContaining('0 of 1 files'), findsWidgets);

      await tester.tap(find.text('Rashid Al-Hulaibah'));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
      expect(repo.getReciter(), Reciter.rashidAlhulaibah);

      await tester.scrollUntilVisible(find.text('Play online'), 200);
      await tester.tap(find.byType(Switch));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
      expect(repo.getAllowStream(), isFalse);
    });
  });
}
