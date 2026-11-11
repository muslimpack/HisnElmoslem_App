import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_object.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/gradient_widget.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally.dart';

/// The count inside a ring that fills as the cycle progresses, with "12 of 33" under
/// it and the number of finished cycles.
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
    final inCycle = counter.isAtCycleEnd ? counter.cycleSize : counter.countInCycle;

    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.biggest.shortestSide;

        return Center(
          child: SizedBox.square(
            dimension: side,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(side * 0.04),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(end: progressOf(counter)),
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return CircularProgressIndicator(
                          value: value,
                          strokeWidth: side * 0.06,
                          strokeCap: StrokeCap.round,
                          backgroundColor: primary.withAlpha(38),
                          valueColor: AlwaysStoppedAnimation<Color>(primary),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(side * 0.16),
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
                              style: TextStyle(
                                fontSize: side * 0.34,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [primary.withAlpha(110), primary],
                            ),
                          ),
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          s.tallyCountOf(inCycle, counter.cycleSize).toArabicNumber(),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      if (counter.cycles > 0)
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 4,
                            children: [
                              Icon(Icons.loop_rounded, size: 16, color: primary),
                              Text(
                                '${counter.cycles}'.toArabicNumber(),
                                style: theme.textTheme.labelLarge?.copyWith(color: primary),
                              ),
                            ],
                          ),
                        ),
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
