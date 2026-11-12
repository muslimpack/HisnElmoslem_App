import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/features/settings/data/repository/app_settings_repo.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally_session_limit.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/components/sheets/tally_session_sheet.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/controller/cubit/tally_audio_cubit.dart';

import 'tally_test_support.dart';

/// Only what the sheet uses: the limit, and setting it.
class _FakeAudio extends Cubit<TallyAudioState> implements TallyAudioCubit {
  _FakeAudio(TallySessionLimit limit) : super(TallyAudioState(limit: limit));

  final saved = <TallySessionLimit>[];

  @override
  Future<void> setLimit(TallySessionLimit limit) async {
    saved.add(limit);
    emit(state.copyWith(limit: limit));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(_FakeAudio audio) {
  return MaterialApp(
    localizationsDelegates: const [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: S.supportedLocales,
    // Not a Scaffold: a modal bottom sheet is not resized by the keyboard either.
    home: Material(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: BlocProvider<TallyAudioCubit>.value(
          value: audio,
          child: const TallySessionSheet(),
        ),
      ),
    ),
  );
}

void main() {
  group('TallySessionLimit.tryParse', () {
    test('accepts whole numbers inside the bounds', () {
      expect(
        TallySessionLimit.tryParse(TallySessionLimitType.minutes, ' 45 '),
        const TallySessionLimit.minutes(45),
      );
      expect(
        TallySessionLimit.tryParse(TallySessionLimitType.count, '250'),
        const TallySessionLimit.count(250),
      );
      expect(
        TallySessionLimit.tryParse(
          TallySessionLimitType.minutes,
          '${TallySessionLimit.maxMinutes}',
        ),
        isNotNull,
      );
    });

    test('rejects empty, zero, negative, text and too large values', () {
      for (final text in ['', '0', '-5', 'abc', '1.5']) {
        expect(TallySessionLimit.tryParse(TallySessionLimitType.count, text), isNull, reason: text);
      }
      expect(
        TallySessionLimit.tryParse(
          TallySessionLimitType.minutes,
          '${TallySessionLimit.maxMinutes + 1}',
        ),
        isNull,
      );
      expect(
        TallySessionLimit.tryParse(
          TallySessionLimitType.count,
          '${TallySessionLimit.maxCount + 1}',
        ),
        isNull,
      );
    });
  });

  group('session sheet', () {
    // Numbers are shown through the digit setting.
    setUp(() => sl.registerLazySingleton(() => AppSettingsRepo(FakeBox())));
    tearDown(sl.reset);

    testWidgets('a value that is not a preset can be typed', (tester) async {
      final audio = _FakeAudio(const TallySessionLimit.minutes(10));
      await tester.pumpWidget(_app(audio));

      await tester.enterText(find.byType(TextField), '45');
      await tester.pump();

      expect(audio.saved.last, const TallySessionLimit.minutes(45));
      expect(audio.state.limit.value, 45);
    });

    testWidgets('an invalid value shows a message and is not used', (tester) async {
      final audio = _FakeAudio(const TallySessionLimit.count(100));
      await tester.pumpWidget(_app(audio));

      await tester.enterText(find.byType(TextField), '0');
      await tester.pump();

      expect(audio.saved, isEmpty);
      expect(find.text('Enter a number from 1 to ${TallySessionLimit.maxCount}'), findsOneWidget);
    });

    testWidgets('tapping a preset fills the field with it', (tester) async {
      final audio = _FakeAudio(const TallySessionLimit.minutes(10));
      await tester.pumpWidget(_app(audio));

      await tester.tap(find.widgetWithText(ChoiceChip, '30 min'));
      await tester.pump();

      expect(audio.state.limit, const TallySessionLimit.minutes(30));
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '30');
    });

    testWidgets('the field stays above the keyboard', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      addTearDown(tester.view.resetViewInsets);

      final audio = _FakeAudio(const TallySessionLimit.count(100));
      await tester.pumpWidget(_app(audio));
      await tester.tap(find.byType(TextField));
      await tester.pump();

      tester.view.viewInsets = const FakeViewPadding(bottom: 400);
      await tester.pumpAndSettle();

      final field = tester.getRect(find.byType(TextField));
      expect(field.bottom, lessThanOrEqualTo(1000 - 400));
    });

    testWidgets('the field is only there for minutes and counts', (tester) async {
      final audio = _FakeAudio(const TallySessionLimit.endless());
      await tester.pumpWidget(_app(audio));

      expect(find.byType(TextField), findsNothing);

      await tester.tap(find.text('For a set time'));
      await tester.pump();
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
