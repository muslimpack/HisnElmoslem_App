import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally_advance_trigger.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally_iteration_mode.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/controller/bloc/tally_bloc.dart';

/// Whether the tally moves to another counter by itself, and when.
class TallyAutoAdvanceSheet extends StatelessWidget {
  const TallyAutoAdvanceSheet({super.key});

  static Future<void> show(BuildContext context) {
    final bloc = context.read<TallyBloc>();
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: const SafeArea(top: false, child: TallyAutoAdvanceSheet()),
      ),
    );
  }

  /// One line for lists and the appbar: "Off", "Circular · After every count".
  static String summary(BuildContext context, TallyLoadedState state) {
    final s = S.of(context);
    if (state.iterationMode == TallyIterationMode.none) return s.tallyAutoAdvanceOff;
    final when = state.advanceTrigger == TallyAdvanceTrigger.perCount
        ? s.tallyAdvanceEveryCount
        : s.tallyAdvanceEveryCycle;
    return '${state.iterationMode.localeName(context)} · $when';
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return BlocBuilder<TallyBloc, TallyState>(
      builder: (context, state) {
        if (state is! TallyLoadedState) return const SizedBox.shrink();
        final bloc = context.read<TallyBloc>();
        final off = state.iterationMode == TallyIterationMode.none;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(s.tallyAutoAdvance, style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                s.tallyAutoAdvanceDesc,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              SegmentedButton<TallyIterationMode>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: TallyIterationMode.none,
                    icon: const Icon(Icons.repeat_one_rounded),
                    label: Text(s.tallyAutoAdvanceOff),
                  ),
                  ButtonSegment(
                    value: TallyIterationMode.circular,
                    icon: const Icon(Icons.repeat_rounded),
                    label: Text(s.circular),
                  ),
                  ButtonSegment(
                    value: TallyIterationMode.shuffle,
                    icon: const Icon(Icons.shuffle_rounded),
                    label: Text(s.shuffle),
                  ),
                ],
                selected: {state.iterationMode},
                onSelectionChanged: (selection) {
                  bloc.add(TallySetIterationModeEvent(selection.first));
                },
              ),
              const SizedBox(height: 24),
              Text(
                s.tallyAdvanceWhen,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: off ? theme.disabledColor : null,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<TallyAdvanceTrigger>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: TallyAdvanceTrigger.perCount,
                    label: Text(s.tallyAdvanceEveryCount),
                  ),
                  ButtonSegment(
                    value: TallyAdvanceTrigger.perCycle,
                    label: Text(s.tallyAdvanceEveryCycle),
                  ),
                ],
                selected: {state.advanceTrigger},
                // Nothing to decide while auto-advance is off.
                onSelectionChanged: off
                    ? null
                    : (selection) => bloc.add(TallySetAdvanceTriggerEvent(selection.first)),
              ),
            ],
          ),
        );
      },
    );
  }
}
