import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/data/models/audio_delay_type_enum.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/data/repository/zikr_audio_player_repo.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/presentation/components/zikr_audio_settings_dialog.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/presentation/controller/cubit/zikr_audio_player_cubit.dart';

import 'zikr_audio_player_cubit_test.dart' show FakePlayer;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ZikrAudioPlayerCubit cubit;

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => Directory.systemTemp.createTempSync('audio_settings_test').path,
    );
    await GetStorage.init('audio_settings_test');
  });

  setUp(() async {
    cubit = ZikrAudioPlayerCubit(
      ZikrAudioPlayerRepo(GetStorage('audio_settings_test')),
      player: FakePlayer(),
    );
    await cubit.init();
  });

  tearDown(() => cubit.close());

  Future<void> pumpSheet(WidgetTester tester) async {
    // A narrow phone, the case that overflowed before.
    tester.view.physicalSize = const Size(360 * 3, 800 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: Scaffold(
          body: BlocProvider.value(value: cubit, child: const ZikrAudioSettingsDialog()),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets("shows the current values and fits a narrow screen", (tester) async {
    await pumpSheet(tester);

    expect(find.text("Playback Speed"), findsOneWidget);
    expect(find.text("Volume"), findsOneWidget);
    expect(find.text("Delay Between Azkar"), findsOneWidget);
    expect(find.text("100%"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets("a speed preset changes and saves the speed", (tester) async {
    await pumpSheet(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, "1.5×"));
    await tester.pump();

    expect(cubit.state.playbackSpeed, 1.5);
    expect(find.text("1.5×"), findsNWidgets(2)); // value chip and the selected preset
  });

  testWidgets("the fixed-time slider only exists for the fixed delay", (tester) async {
    await cubit.saveSettings(delayType: AudioDelayTypeEnum.none);
    await pumpSheet(tester);
    expect(find.byType(Slider), findsNWidgets(2)); // speed and volume

    await tester.tap(find.widgetWithText(ChoiceChip, "Fixed Time"));
    await tester.pump();

    expect(cubit.state.delayType, AudioDelayTypeEnum.fixedTime);
    expect(find.byType(Slider), findsNWidgets(3));
  });
}
