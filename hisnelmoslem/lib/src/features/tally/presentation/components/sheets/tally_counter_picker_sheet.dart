import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_object.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/components/tally_actions.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/controller/bloc/tally_bloc.dart';

/// A quick way to jump to another counter from the counting screen.
class TallyCounterPickerSheet extends StatelessWidget {
  final BuildContext parentContext;

  const TallyCounterPickerSheet({super.key, required this.parentContext});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => SafeArea(
        top: false,
        child: TallyCounterPickerSheet(parentContext: context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = parentContext.read<TallyBloc>().state;
    if (state is! TallyLoadedState) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(S.of(context).tallyPickCounter, style: theme.textTheme.titleLarge),
          ),
        ),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final counter in state.allCounters)
                ListTile(
                  selected: counter.isActivated,
                  leading: Icon(
                    counter.isActivated
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                  ),
                  title: Text(counter.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 12,
                    children: [
                      if (counter.hasAudio) const Icon(Icons.mic_rounded, size: 18),
                      Text('${counter.count}'.toArabicNumber()),
                    ],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    if (parentContext.mounted && !counter.isActivated) {
                      TallyActions.select(parentContext, counter);
                    }
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
