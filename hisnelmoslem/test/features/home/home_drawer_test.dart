import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/home_drawer/home_drawer.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/home_drawer/home_drawer_controller.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/home_drawer/home_drawer_hint.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/home_drawer/pull_to_open_drawer.dart';

late HomeDrawerController _controller;

Widget _app({
  Locale locale = const Locale('en'),
  VoidCallback? onShown,
  bool hintShown = true,
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: S.supportedLocales,
    home: Scaffold(
      body: HomeDrawer(
        menu: const Center(child: Text('MENU')),
        child: HomeDrawerHint(
          alreadyShown: hintShown,
          onShown: onShown ?? () {},
          child: Builder(
            builder: (context) {
              _controller = HomeDrawerScope.of(context);
              return Scaffold(
                body: PullToOpenDrawer(
                  builder: (context, physics) => DefaultTabController(
                    length: 3,
                    child: TabBarView(
                      physics: physics,
                      children: const [
                        Center(child: Text('tab0')),
                        Center(child: Text('tab1')),
                        Center(child: Text('tab2')),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('toggle opens and closes the drawer', (tester) async {
    await tester.pumpWidget(_app());
    expect(_controller.value, 0);

    _controller.toggle();
    await tester.pumpAndSettle();
    expect(_controller.value, 1);

    _controller.toggle();
    await tester.pumpAndSettle();
    expect(_controller.value, 0);
  });

  testWidgets('pulling the first tab toward the start edge opens the drawer (LTR)', (tester) async {
    await tester.pumpWidget(_app());

    final gesture = await tester.startGesture(const Offset(200, 300));
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(20, 0));
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(_controller.value, greaterThan(0.2), reason: 'follows the finger');
    expect(_controller.value, lessThan(1));

    await gesture.up();
    await tester.pumpAndSettle();
    expect(_controller.value, 1);
    expect(find.text('tab0'), findsOneWidget);
  });

  testWidgets('a short pull snaps back closed', (tester) async {
    await tester.pumpWidget(_app());

    final gesture = await tester.startGesture(const Offset(200, 300));
    for (var i = 0; i < 4; i++) {
      await gesture.moveBy(const Offset(10, 0));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(_controller.value, greaterThan(0));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(_controller.value, 0);
  });

  testWidgets('pulling the first tab works the same in RTL', (tester) async {
    await tester.pumpWidget(_app(locale: const Locale('ar')));

    final gesture = await tester.startGesture(const Offset(400, 300));
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(-20, 0));
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(_controller.value, greaterThan(0.2));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(_controller.value, 1);
  });

  testWidgets('swiping toward the next tab changes tab and leaves the drawer closed', (
    tester,
  ) async {
    await tester.pumpWidget(_app());

    await tester.fling(find.text('tab0'), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();
    expect(_controller.value, 0);
    expect(find.text('tab1'), findsOneWidget);
  });

  testWidgets('tapping the dimmed screen closes the drawer', (tester) async {
    await tester.pumpWidget(_app());
    _controller.open();
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(780, 300));
    await tester.pumpAndSettle();
    expect(_controller.value, 0);
  });

  testWidgets('swiping the menu toward the closed side closes the drawer (LTR)', (tester) async {
    await tester.pumpWidget(_app());
    _controller.open();
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(const Offset(150, 300));
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(-25, 0));
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(_controller.value, lessThan(1), reason: 'follows the finger');
    expect(_controller.value, greaterThan(0));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(_controller.value, 0);
  });

  testWidgets('swiping the menu toward the closed side closes the drawer (RTL)', (tester) async {
    await tester.pumpWidget(_app(locale: const Locale('ar')));
    _controller.open();
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(const Offset(650, 300));
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(25, 0));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pumpAndSettle();
    expect(_controller.value, 0);
  });

  testWidgets('Esc closes an open drawer', (tester) async {
    await tester.pumpWidget(_app());
    _controller.open();
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(_controller.value, 0);
  });

  testWidgets('Esc does nothing while the drawer is closed', (tester) async {
    await tester.pumpWidget(_app());
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(_controller.value, 0);
  });

  testWidgets('the back button closes an open drawer first', (tester) async {
    await tester.pumpWidget(_app());
    _controller.open();
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(_controller.value, 0);
  });

  testWidgets('the hint peeks once and reports it was shown', (tester) async {
    var shown = 0;
    await tester.pumpWidget(_app(hintShown: false, onShown: () => shown++));

    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 300));
    expect(shown, 1);
    expect(_controller.value, greaterThan(0));

    // The peek holds for a moment (a plain timer, so no frames), then closes again.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(_controller.value, 0);
  });

  testWidgets('the hint does not run when it was already shown', (tester) async {
    var shown = 0;
    await tester.pumpWidget(_app(onShown: () => shown++));
    await tester.pump(const Duration(seconds: 3));
    expect(shown, 0);
    expect(_controller.value, 0);
  });

  testWidgets('the hint is skipped if the user opened the drawer first', (tester) async {
    var shown = 0;
    await tester.pumpWidget(_app(hintShown: false, onShown: () => shown++));
    _controller.open();
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();
    expect(shown, 1, reason: 'still marked as shown');
    expect(_controller.value, 1, reason: 'not closed by the peek');
  });

  testWidgets('wide windows show the menu as a permanent panel', (tester) async {
    tester.view.physicalSize = const Size(1400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app());
    expect(find.text('MENU'), findsOneWidget);
    expect(HomeDrawerScope.isPermanentOf(tester.element(find.text('tab0'))), isTrue);

    _controller.open();
    await tester.pumpAndSettle();
    expect(_controller.value, 0);
  });
}
