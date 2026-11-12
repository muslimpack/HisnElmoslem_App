import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/components/tally_counter_view_bottom_bar.dart';

void main() {
  testWidgets('a dock tile can be activated by a screen reader', (tester) async {
    final handle = tester.ensureSemantics();
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TallyDockTile(icon: Icons.tune_rounded, label: 'Options', onTap: () => taps++),
        ),
      ),
    );

    final node = tester.getSemantics(find.byType(TallyDockTile));
    expect(node, isSemantics(isButton: true, label: 'Options', hasTapAction: true));

    tester.semantics.tap(find.semantics.byLabel('Options'));
    expect(taps, 1);
    handle.dispose();
  });
}
