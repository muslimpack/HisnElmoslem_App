import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/data/audio_file_store.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/data/http_audio_downloader.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/data/reciter_audio_repo.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/byte_format.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/download_plan.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/reciter.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/components/download_confirm_dialog.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/controller/reciter_downloads_cubit.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/screens/download_center_screen.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/screens/reciter_titles_screen.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

class _OkDownloader implements AudioDownloader {
  @override
  Future<int?> contentLength(String url) async => 1024 * 1024;

  @override
  Future<int> download({
    required String url,
    required File target,
    void Function(int received, int? total)? onProgress,
    DownloadCancelToken? cancel,
  }) async {
    await target.parent.create(recursive: true);
    await target.writeAsBytes(List.filled(1024, 1));
    return 1024;
  }
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

  group('download center', () {
    late Directory root;
    late ReciterAudioRepo repo;
    late AudioFileStore store;

    final contents = [
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
      const DbContent(
        id: 2,
        content: 'y',
        titleId: 2,
        order: 2,
        count: 1,
        fadl: '',
        source: '',
        search: '',
        hokm: '',
        audio: '',
        hasAudio: false,
        audioRemoteOk: true,
        audioUrls: {
          'hamad_alduraihem': ['https://cdn.binwahaf.com/uploads/2025/12/0002.mp3'],
        },
      ),
    ];

    Future<List<DbTitle>> titles() async => const [
      DbTitle(id: 1, name: 'Waking up', freq: '', order: 1),
      DbTitle(id: 2, name: 'Morning', freq: '', order: 2),
      DbTitle(id: 3, name: 'No audio title', freq: '', order: 3),
    ];

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
      store = AudioFileStore(() async => root);
      sl
        ..registerSingleton<ReciterAudioRepo>(repo)
        ..registerSingleton<AudioFileStore>(store)
        ..registerSingleton<ReciterDownloadsCubit>(
          ReciterDownloadsCubit(
            downloader: _OkDownloader(),
            store: store,
            repo: repo,
            loadContents: ({int? titleId}) async =>
                titleId == null ? contents : contents.where((c) => c.titleId == titleId).toList(),
          ),
        );
    });

    tearDown(() async {
      await GetIt.instance.reset();
      if (root.existsSync()) root.deleteSync(recursive: true);
    });

    void phone(WidgetTester tester) {
      tester.view.physicalSize = const Size(360 * 3, 900 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
    }

    /// Real async (files, storage) needs real time next to the fake clock.
    Future<void> settle(WidgetTester tester) async {
      for (var i = 0; i < 12; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 60)));
        await tester.pump();
      }
    }

    testWidgets('lists the reciters with what is on the phone and saves the streaming switch', (
      tester,
    ) async {
      phone(tester);
      await tester.pumpWidget(app(const DownloadCenterScreen()));
      await settle(tester);

      expect(find.text('Download center'), findsOneWidget);
      expect(find.text('Hamad Al-Duraihem'), findsOneWidget);
      expect(find.text('Sulaiman Al-Shuwaihi'), findsOneWidget);
      expect(find.text('Rashid Al-Hulaibah'), findsOneWidget);
      expect(find.text('Current reciter'), findsOneWidget);
      expect(find.textContaining('0 of 2 files'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Play online'), 200);
      await tester.tap(find.byType(Switch));
      await settle(tester);
      expect(repo.getAllowStream(), isFalse);
    });

    testWidgets('a reciter lists its titles; a downloaded one offers delete, the others download', (
      tester,
    ) async {
      phone(tester);
      // Title 1 is fully downloaded, title 2 is not.
      final file = await tester.runAsync(
        () => store.fileOf(
          Reciter.hamadAlduraihem,
          'https://cdn.binwahaf.com/uploads/2025/12/0001.mp3',
        ),
      );
      await tester.runAsync(() async {
        await file!.parent.create(recursive: true);
        await file.writeAsBytes(List.filled(2048, 1));
      });

      await tester.pumpWidget(
        app(ReciterTitlesScreen(reciter: Reciter.hamadAlduraihem, loadTitles: titles)),
      );
      await settle(tester);

      expect(find.text('Waking up'), findsOneWidget);
      expect(find.text('Morning'), findsOneWidget);
      expect(find.text('No audio title'), findsNothing);
      // The group label and the status of the downloaded title.
      expect(find.textContaining('Downloaded'), findsNWidgets(2));

      // Title 1 (downloaded): delete only. Title 2: download only.
      final wakingRow = find.ancestor(of: find.text('Waking up'), matching: find.byType(ListTile));
      final morningRow = find.ancestor(of: find.text('Morning'), matching: find.byType(ListTile));
      expect(
        find.descendant(of: wakingRow, matching: find.byIcon(Icons.delete_outline_rounded)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: wakingRow, matching: find.byIcon(Icons.download_rounded)),
        findsNothing,
      );
      expect(
        find.descendant(of: morningRow, matching: find.byIcon(Icons.download_rounded)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: morningRow, matching: find.byIcon(Icons.delete_outline_rounded)),
        findsNothing,
      );

      // Deleting title 1 asks first, then removes its file.
      await tester.tap(
        find.descendant(of: wakingRow, matching: find.byIcon(Icons.delete_outline_rounded)),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Delete the downloaded audio of'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await settle(tester);

      expect(file!.existsSync(), isFalse);
      expect(
        find.descendant(of: wakingRow, matching: find.byIcon(Icons.download_rounded)),
        findsOneWidget,
      );
    });

    testWidgets('the header can switch to this reciter', (tester) async {
      phone(tester);
      await tester.pumpWidget(
        app(ReciterTitlesScreen(reciter: Reciter.rashidAlhulaibah, loadTitles: titles)),
      );
      await settle(tester);

      await tester.tap(find.text('Use this reciter'));
      await settle(tester);

      expect(repo.getReciter(), Reciter.rashidAlhulaibah);
      expect(find.text('Current reciter'), findsOneWidget);
    });

    testWidgets('downloaded titles come first, under their own label', (tester) async {
      phone(tester);
      // Title 2 is downloaded, title 1 is not: title 2 must be listed above title 1.
      final file = await tester.runAsync(
        () => store.fileOf(
          Reciter.hamadAlduraihem,
          'https://cdn.binwahaf.com/uploads/2025/12/0002.mp3',
        ),
      );
      await tester.runAsync(() async {
        await file!.parent.create(recursive: true);
        await file.writeAsBytes(List.filled(2048, 1));
      });

      await tester.pumpWidget(
        app(ReciterTitlesScreen(reciter: Reciter.hamadAlduraihem, loadTitles: titles)),
      );
      await settle(tester);

      expect(find.text('Not downloaded'), findsOneWidget);
      final morningY = tester.getTopLeft(find.text('Morning')).dy;
      final wakingY = tester.getTopLeft(find.text('Waking up')).dy;
      expect(morningY, lessThan(wakingY));
      expect(tester.getTopLeft(find.text('Not downloaded')).dy, lessThan(wakingY));
      expect(tester.getTopLeft(find.text('Not downloaded')).dy, greaterThan(morningY));
    });

    testWidgets('search compares the diacritics-free search text, not the decorated name', (
      tester,
    ) async {
      phone(tester);
      Future<List<DbTitle>> decorated() async => const [
        DbTitle(id: 1, name: 'أَذْكَارُ الصَّبَاحِ', freq: '', order: 1, search: 'أذكار الصباح'),
        DbTitle(id: 2, name: 'أَذْكَارُ الْمَسَاءِ', freq: '', order: 2, search: 'أذكار المساء'),
      ];

      await tester.pumpWidget(
        app(ReciterTitlesScreen(reciter: Reciter.hamadAlduraihem, loadTitles: decorated)),
      );
      await settle(tester);
      expect(find.text('أَذْكَارُ الصَّبَاحِ'), findsOneWidget);
      expect(find.text('أَذْكَارُ الْمَسَاءِ'), findsOneWidget);

      // Plain letters, no diacritics, a ta marbuta typed as ha: still matches the first title.
      await tester.enterText(find.byType(TextField), 'الصباح');
      await settle(tester);
      expect(find.text('أَذْكَارُ الصَّبَاحِ'), findsOneWidget);
      expect(find.text('أَذْكَارُ الْمَسَاءِ'), findsNothing);

      await tester.enterText(find.byType(TextField), 'غير موجود');
      await settle(tester);
      expect(find.text('No results found'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await settle(tester);
      expect(find.text('أَذْكَارُ الْمَسَاءِ'), findsOneWidget);
    });
  });
}
