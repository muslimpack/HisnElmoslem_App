import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_object.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/gradient_widget.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally.dart';

/// The big count inside a ring that fills as the cycle progresses, with "12 / 33"
/// under it and the number of finished cycles.
class TallyCounterRing extends StatelessWidget {
  final DbTally counter;

  const TallyCounterRing({super.key, required this.counter});

  /// Full at the end of a cycle (33 of 33), empty again with the next count.
  static double progressOf(DbTally counter) {
    if (counter.isAtCycleEnd) return 1;
    return counter.countInCycle / counter.cycleSize;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final s = S.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.biggest.shortestSide;
        final countStyle = TextStyle(
          fontSize: side * 0.3,
          fontWeight: FontWeight.bold,
          height: 1,
        );

        return Center(
          child: SizedBox.square(
            dimension: side,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(side * 0.03),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(end: progressOf(counter)),
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return CircularProgressIndicator(
                          value: value,
                          strokeWidth: side * 0.05,
                          strokeCap: StrokeCap.round,
                          backgroundColor: primary.withAlpha(38),
                          valueColor: AlwaysStoppedAnimation<Color>(primary),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(side * 0.14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: GradientWidget(
                            Text(
                              '${counter.count}'.toArabicNumber(),
                              textAlign: TextAlign.center,
                              style: countStyle,
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [primary.withAlpha(110), primary],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: side * 0.03),
                      Text(
                        '${counter.isAtCycleEnd ? counter.cycleSize : counter.countInCycle}'
                                ' / ${counter.cycleSize}'
                            .toArabicNumber(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      if (counter.cycles > 0) ...[
                        SizedBox(height: side * 0.02),
                        Chip(
                          avatar: Icon(Icons.loop_rounded, size: 18, color: primary),
                          label: Text(s.tallyCyclesDone(counter.cycles).toArabicNumber()),
                          visualDensity: VisualDensity.compact,
                          side: BorderSide.none,
                          backgroundColor: primary.withAlpha(30),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
