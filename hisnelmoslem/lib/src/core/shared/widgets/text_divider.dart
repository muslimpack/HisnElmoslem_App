import 'package:flutter/material.dart';
import 'package:hisnelmoslem/src/features/home_search/presentation/components/squiggly_line_painter.dart';

class TextDivider extends StatelessWidget {
  const TextDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final Color lineColor = Theme.of(context).dividerColor;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          Expanded(
            child: CustomPaint(
              size: const Size(double.infinity, 10),
              painter: SquigglyLinePainter(color: lineColor),
            ),
          ),
        ],
      ),
    );
  }
}
