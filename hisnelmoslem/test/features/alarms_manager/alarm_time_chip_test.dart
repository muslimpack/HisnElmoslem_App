import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/presentation/components/alarm_time_chip.dart';

Widget _app({required Widget child, Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: S.localizationsDelegates,
    supportedLocales: S.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('shows the reminder time and opens the editor on tap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _app(
        child: AlarmTimeChip(hour: 6, minute: 30, isActive: true, onTap: () => taps++),
      ),
    );

    expect(find.text('6:30 AM'), findsOneWidget);
    await tester.tap(find.byType(AlarmTimeChip));
    expect(taps, 1);
  });

  for (final locale in const [Locale('en'), Locale('ar')]) {
    testWidgets('fits in a narrow title card (${locale.languageCode})', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _app(
          locale: locale,
          child: ListTile(
            leading: const SizedBox(width: 90, child: Text('29')),
            title: const Text('الأذكار بعد السلام من الصلاة الأذكار بعد السلام من الصلاة'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AlarmTimeChip(hour: 17, minute: 0, isActive: false, onTap: () {}),
                IconButton(icon: const Icon(Icons.notifications_off), onPressed: () {}),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  }
}
