import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/data/audio_file_store.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/data/http_audio_downloader.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/data/reciter_audio_repo.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/reciter.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/components/download_activity_pill.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/controller/reciter_downloads_cubit.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/controller/reciter_downloads_state.dart';

class _Idle implements AudioDownloader {
  @override
  Future<int?> contentLength(String url) async => null;

  @override
  Future<int> download({
    required String url,
    required File target,
    void Function(int received, int? total)? onProgress,
    DownloadCancelToken? cancel,
  }) async => 0;
}

/// A cubit whose state the test sets directly.
class _ShownCubit extends ReciterDownloadsCubit {
  _ShownCubit()
    : super(
        downloader: _Idle(),
        store: AudioFileStore(() async => Directory.systemTemp),
        repo: ReciterAudioRepo(GetStorage('pill_test')),
        loadContents: ({int? titleId}) async => const [],
      );

  void show(ReciterDownloadsState state) => emit(state);
}

ReciterDownloadsState state(DownloadStatus status, {int done = 3, int total = 10, int failed = 0}) {
  return ReciterDownloadsState(
    status: status,
    reciter: Reciter.hamadAlduraihem,
    totalFiles: total,
    doneFiles: done,
    failedUrls: [for (var i = 0; i < failed; i++) 'u$i'],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => Directory.systemTemp.createTempSync('pill_test').path,
    );
    await GetStorage.init('pill_test');
  });

  late _ShownCubit cubit;
  var opened = 0;

  setUp(() {
    cubit = _ShownCubit();
    opened = 0;
  });

  tearDown(() => cubit.close());

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: Scaffold(
          body: Stack(
            children: [
              const SizedBox.expand(),
              DownloadActivityPill(downloads: cubit, onTap: () => opened++),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('nothing shows while idle', (tester) async {
    await pump(tester);
    expect(find.textContaining('Downloading'), findsNothing);
  });

  testWidgets('a running download shows its progress and can be paused or opened', (tester) async {
    await pump(tester);
    cubit.show(state(DownloadStatus.running));
    await tester.pumpAndSettle();

    expect(find.text('Downloading 3 of 10'), findsOneWidget);
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);

    await tester.tap(find.text('Downloading 3 of 10'));
    expect(opened, 1);
  });

  testWidgets('a paused download offers resume and can be closed', (tester) async {
    await pump(tester);
    cubit.show(state(DownloadStatus.paused));
    await tester.pumpAndSettle();

    expect(find.text('Paused at 3 of 10'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Paused at 3 of 10'), findsNothing);
  });

  testWidgets('a finished download reports it and then goes away by itself', (tester) async {
    await pump(tester);
    cubit.show(state(DownloadStatus.running));
    await tester.pumpAndSettle();
    cubit.show(state(DownloadStatus.completed, done: 10));
    await tester.pumpAndSettle();
    expect(find.text('Download finished'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('Download finished'), findsNothing);
  });

  testWidgets('a download with failed files stays, with a retry button', (tester) async {
    await pump(tester);
    cubit.show(state(DownloadStatus.completed, done: 8, failed: 2));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 6));

    expect(find.text('2 files could not be downloaded'), findsOneWidget);
    expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
  });
}
