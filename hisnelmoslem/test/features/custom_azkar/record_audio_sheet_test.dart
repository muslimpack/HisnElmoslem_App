import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/data/services/audio_preview_player.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/data/services/audio_recorder_service.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/data/services/custom_audio_storage.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/bloc/audio_preview/audio_preview_cubit.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/bloc/zikr_recorder/zikr_recorder_cubit.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/components/record_audio_sheet.dart';

class _FakeRecorder implements AudioRecorderService {
  String? path;

  @override
  Future<bool> ensurePermission() async => true;

  @override
  Future<void> start(String path) async {
    this.path = path;
    File(path).writeAsBytesSync([1, 2, 3]);
  }

  @override
  Future<String?> stop() async => path;

  @override
  Future<void> cancel() async {}

  @override
  Stream<double> levels() => const Stream.empty();

  @override
  Future<void> dispose() async {}
}

class _FakePlayer implements AudioPreviewPlayer {
  @override
  Future<void> play({String? filePath, String? asset}) async {}
  @override
  Future<void> pause() async {}
  @override
  Future<void> resume() async {}
  @override
  Future<void> stop() async {}
  @override
  Future<void> seek(Duration position) async {}
  @override
  Stream<Duration> get positionStream => const Stream.empty();
  @override
  Stream<Duration> get durationStream => const Stream.empty();
  @override
  Stream<void> get completeStream => const Stream.empty();
  @override
  Future<void> dispose() async {}
}

void main() {
  final sl = GetIt.instance;
  late Directory dir;
  late LocalCustomAudioStorage storage;
  RecordAudioResult? result;
  var closed = false;

  setUp(() {
    result = null;
    closed = false;
    dir = Directory.systemTemp.createTempSync('sheet_test');
    storage = LocalCustomAudioStorage(directoryOverride: dir);
    sl
      ..registerSingleton<CustomAudioStorage>(storage)
      ..registerFactory(() => ZikrRecorderCubit(recorder: _FakeRecorder(), storage: storage))
      ..registerFactory(() => AudioPreviewCubit(_FakePlayer()));
  });

  tearDown(() async {
    await sl.reset();
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  /// Real file IO needs the real event loop.
  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 120)));
    await tester.pump();
  }

  Future<void> openSheet(WidgetTester tester, {String? existingFile}) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await RecordAudioSheet.show(
                  context,
                  zikrText: "سبحان الله",
                  existingFile: existingFile,
                );
                closed = true;
              },
              child: const Text("open"),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text("open"));
    await tester.pumpAndSettle();
  }

  Future<void> recordTake(WidgetTester tester) async {
    await tester.tap(find.byTooltip("Start recording"));
    await settle(tester);
    expect(find.byTooltip("Stop recording"), findsOneWidget);

    await tester.tap(find.byTooltip("Stop recording"));
    await settle(tester);
    expect(find.text("Use this recording"), findsOneWidget);
  }

  testWidgets("a long zikr is shown in full inside a scrollable card", (tester) async {
    final longText = List.filled(60, "سبحان الله وبحمده").join(" ");
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: Scaffold(body: RecordZikrCard(text: longText)),
      ),
    );

    final text = tester.widget<Text>(find.text(longText));
    expect(text.maxLines, isNull);
    expect(text.overflow, isNot(TextOverflow.ellipsis));
    expect(
      find.descendant(of: find.byType(RecordZikrCard), matching: find.byType(Scrollable)),
      findsOneWidget,
    );

    // The card is capped, so the text overflows it and can be scrolled.
    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
    expect(scrollable.position.maxScrollExtent, greaterThan(0));
  });

  testWidgets("record, listen and use the recording", (tester) async {
    await openSheet(tester);
    expect(find.text("سبحان الله"), findsOneWidget);

    await recordTake(tester);
    expect(find.text("Listen to your recording"), findsOneWidget);

    await tester.tap(find.text("Use this recording"));
    await tester.pumpAndSettle();

    expect(closed, isTrue);
    expect(result?.fileName, isNotNull);
    expect(await tester.runAsync(() => storage.exists(result!.fileName!)), isTrue);
  });

  testWidgets("closing with an unsaved take asks first and deletes it", (tester) async {
    await openSheet(tester);
    await recordTake(tester);
    final take = dir.listSync().single;

    // Declining keeps everything.
    await tester.tap(find.byTooltip("Cancel"));
    await tester.pumpAndSettle();
    expect(find.text("Discard this recording?"), findsOneWidget);
    await tester.tap(find.text("No"));
    await tester.pumpAndSettle();
    expect(closed, isFalse);
    expect(take.existsSync(), isTrue);

    await tester.tap(find.byTooltip("Cancel"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Yes"));
    await tester.pumpAndSettle(); // dialog closes, then the take is deleted for real
    // Deleting the file is several real IO steps, each resumed by a pump.
    for (var i = 0; i < 3; i++) {
      await settle(tester);
      await tester.pumpAndSettle();
    }

    expect(closed, isTrue);
    expect(result, isNull);
    expect(take.existsSync(), isFalse);
  });

  testWidgets("an existing recording can be deleted from the sheet", (tester) async {
    File('${dir.path}/old.m4a').writeAsBytesSync([1]);
    await openSheet(tester, existingFile: "old.m4a");

    expect(find.text("Your recording"), findsOneWidget);
    await tester.tap(find.text("Delete my recording"));
    await tester.pumpAndSettle();
    expect(find.text("This zikr will have no audio."), findsOneWidget);
    await tester.tap(find.text("Yes"));
    await tester.pumpAndSettle();

    expect(closed, isTrue);
    expect(result?.isRemoval, isTrue);
  });
}
