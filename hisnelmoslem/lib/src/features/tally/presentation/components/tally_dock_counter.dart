import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_object.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/components/tally_actions.dart';

/// The count inside the cycle, in a button with a ring that fills as the cycle goes. The
/// same idea as the counter of the zikr viewer. Tapping counts.
class TallyDockCounter extends StatelessWidget {
  final DbTally counter;

  const TallyDockCounter({super.key, required this.counter});

  static const double size = 96;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    final atEnd = counter.isAtCycleEnd;

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: s.tallyCountSemantics(counter.title, counter.count, counter.cycleSize),
      onTapHint: s.tallyAddOne,
      onTap: () => TallyActions.count(context),
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(end: counter.cycleProgress),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              builder: (context, value, _) => CircularProgressIndicator(
                value: value,
                strokeWidth: 7,
                strokeCap: StrokeCap.round,
                backgroundColor: theme.colorScheme.primary.withAlpha(40),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Material(
                color: atEnd ? theme.colorScheme.primary : theme.colorScheme.primaryContainer,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => TallyActions.count(context),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      child: FittedBox(
                        key: ValueKey<int>(counter.shownInCycle),
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            '${counter.shownInCycle}'.toArabicNumber(),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: atEnd
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
