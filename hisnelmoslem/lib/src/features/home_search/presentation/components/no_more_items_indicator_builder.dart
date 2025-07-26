import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/home_search/presentation/components/squiggly_line_painter.dart';

class NoMoreItemsIndicatorBuilder extends StatelessWidget {
  const NoMoreItemsIndicatorBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    final Color lineColor = Theme.of(context).dividerColor;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
      child: Row(
        children: <Widget>[
          Expanded(
            child: CustomPaint(
              size: const Size(double.infinity, 10),
              painter: SquigglyLinePainter(color: lineColor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              S.of(context).noMoreResults,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
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
