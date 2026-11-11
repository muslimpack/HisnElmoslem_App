import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/components/sheets/tally_auto_advance_sheet.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/components/tally_actions.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/controller/bloc/tally_bloc.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/controller/cubit/tally_audio_cubit.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/presentation/components/zikr_audio_settings_dialog.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

/// Everything about the active counter that is not counting: edit, voice, audio
/// settings, auto-advance and reset.
class TallyMoreSheet extends StatelessWidget {
  final DbTally counter;

  /// The screen the sheet was opened from. The actions run on it, because the sheet
  /// is a separate route.
  final BuildContext parentContext;

  const TallyMoreSheet({super.key, required this.counter, required this.parentContext});

  static Future<void> show(BuildContext context) {
    final state = context.read<TallyBloc>().state;
    if (state is! TallyLoadedState || state.activeCounter == null) return Future.value();
    final counter = state.activeCounter!;

    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => SafeArea(
        top: false,
        child: TallyMoreSheet(counter: counter, parentContext: context),
      ),
    );
  }

  void _run(BuildContext sheetContext, VoidCallback action) {
    Navigator.pop(sheetContext);
    if (parentContext.mounted) action();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text(s.edit),
            onTap: () => _run(context, () => TallyActions.edit(parentContext, counter)),
          ),
          ListTile(
            leading: const Icon(Icons.mic_rounded),
            title: Text(counter.hasAudio ? s.recordMyVoiceBadge : s.recordVoice),
            subtitle: Text(s.tallyVoiceHint),
            onTap: () => _run(context, () => TallyActions.recordVoice(parentContext, counter)),
          ),
          ListTile(
            leading: const Icon(Icons.tune_rounded),
            title: Text(s.audioPlayerSettings),
            onTap: () => _run(context, () {
              ZikrAudioSettingsDialog.show(
                parentContext,
                cubit: parentContext.read<TallyAudioCubit>().engine,
              );
            }),
          ),
          BlocBuilder<TallyBloc, TallyState>(
            bloc: parentContext.read<TallyBloc>(),
            builder: (context, state) {
              final mode = state is TallyLoadedState ? state.iterationMode : null;
              return ListTile(
                leading: Icon(MdiIcons.repeat),
                title: Text(s.tallyAutoAdvance),
                subtitle: mode == null
                    ? null
                    : Text(TallyAutoAdvanceSheet.summary(context, state as TallyLoadedState)),
                onTap: () => _run(context, () => TallyAutoAdvanceSheet.show(parentContext)),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.restart_alt_rounded, color: theme.colorScheme.error),
            title: Text(s.reset, style: TextStyle(color: theme.colorScheme.error)),
            onTap: () => _run(context, () => TallyActions.resetActive(parentContext)),
          ),
        ],
      ),
    );
  }
}
