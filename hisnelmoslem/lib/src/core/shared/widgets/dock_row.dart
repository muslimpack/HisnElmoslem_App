import 'package:flutter/material.dart';

/// The three controls of a bottom dock in a fixed order that does not follow the text
/// direction: the play controls on the left, the counter in the middle and the options
/// on the right, in left-to-right and right-to-left alike. The two sides share the room
/// equally, so the counter stays in the middle.
class DockRow extends StatelessWidget {
  final Widget play;
  final Widget counter;
  final Widget options;

  const DockRow({super.key, required this.play, required this.counter, required this.options});

  @override
  Widget build(BuildContext context) {
    return Row(
      // Only the order of these three; their insides keep the direction of the app.
      textDirection: TextDirection.ltr,
      children: [
        Expanded(child: Center(child: play)),
        counter,
        Expanded(child: Center(child: options)),
      ],
    );
  }
}
