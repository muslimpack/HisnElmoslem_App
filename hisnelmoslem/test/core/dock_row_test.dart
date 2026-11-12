import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/dock_row.dart';

Widget _app(TextDirection direction) {
  return MaterialApp(
    home: Directionality(
      textDirection: direction,
      child: const Scaffold(
        body: DockRow(
          play: Text('play'),
          counter: SizedBox(width: 96, height: 96, child: Text('counter')),
          options: Text('options'),
        ),
      ),
    ),
  );
}

void main() {
  for (final direction in TextDirection.values) {
    testWidgets('play is on the left and options on the right in $direction', (tester) async {
      await tester.pumpWidget(_app(direction));

      final play = tester.getCenter(find.text('play')).dx;
      final counter = tester.getCenter(find.text('counter')).dx;
      final options = tester.getCenter(find.text('options')).dx;

      expect(play, lessThan(counter));
      expect(counter, lessThan(options));
      // The counter stays in the middle: both sides are the same distance away.
      expect(counter - play, closeTo(options - counter, 0.5));
    });
  }

  testWidgets('the text inside keeps the direction of the app', (tester) async {
    await tester.pumpWidget(_app(TextDirection.rtl));

    final direction = Directionality.of(tester.element(find.text('play')));
    expect(direction, TextDirection.rtl);
  });
}
