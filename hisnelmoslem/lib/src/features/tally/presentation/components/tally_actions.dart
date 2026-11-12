import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/models/editor_result.dart';
import 'package:hisnelmoslem/src/core/shared/dialogs/yes_no_dialog.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/components/record_audio_sheet.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/components/dialogs/tally_editor.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/controller/bloc/tally_bloc.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/controller/cubit/tally_audio_cubit.dart';

/// What the buttons of the tally do. They need a context under the [TallyBloc] and the
/// [TallyAudioCubit] providers.
abstract final class TallyActions {
  static const Duration _undoTime = Duration(seconds: 6);

  /// A voice session follows the active counter, so it ends when another one is chosen.
  static void _stopVoice(BuildContext context) {
    final audio = context.read<TallyAudioCubit>();
    if (audio.state.isActive) audio.stop();
  }

  static void select(BuildContext context, DbTally counter) {
    _stopVoice(context);
    context.read<TallyBloc>().add(
      TallyToggleCounterActivationEvent(counter: counter, activate: true),
    );
  }

  static void previous(BuildContext context) {
    _stopVoice(context);
    context.read<TallyBloc>().add(TallyPreviousCounterEvent());
  }

  static void next(BuildContext context) {
    _stopVoice(context);
    context.read<TallyBloc>().add(TallyNextCounterEvent());
  }

  static void count(BuildContext context) {
    context.read<TallyBloc>().add(const TallyIncreaseActiveCounterEvent());
  }

  static void decrease(BuildContext context) {
    context.read<TallyBloc>().add(TallyDecreaseActiveCounterEvent());
  }

  /// Zeroes the active counter; the snackbar can put the number back.
  static void resetActive(BuildContext context) {
    final bloc = context.read<TallyBloc>();
    final state = bloc.state;
    if (state is! TallyLoadedState) return;
    final active = state.activeCounter;
    if (active == null) return;

    bloc.add(TallyResetActiveCounterEvent());
    _showUndo(
      context,
      S.of(context).tallyCounterReset,
      () => bloc.add(TallyRestoreCountersEvent(counters: [active])),
    );
  }

  static void resetAll(BuildContext context) {
    final bloc = context.read<TallyBloc>();
    final state = bloc.state;
    if (state is! TallyLoadedState) return;
    final before = state.allCounters;

    bloc.add(TallyResetAllCountersEvent());
    _showUndo(
      context,
      S.of(context).tallyAllCountersReset,
      () => bloc.add(TallyRestoreCountersEvent(counters: before)),
    );
  }

  static void _showUndo(BuildContext context, String message, VoidCallback onUndo) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: _undoTime,
          action: SnackBarAction(label: S.of(context).undo, onPressed: onUndo),
        ),
      );
  }

  static Future<void> add(BuildContext context) async {
    final bloc = context.read<TallyBloc>();
    final EditorResult<DbTally>? result = await showTallyEditorDialog(context: context);
    if (result == null) return;
    bloc.add(TallyAddCounterEvent(counter: result.value));
  }

  /// Opens the editor; deleting asks first.
  static Future<void> edit(BuildContext context, DbTally counter) async {
    final bloc = context.read<TallyBloc>();
    final audio = context.read<TallyAudioCubit>();
    final EditorResult<DbTally>? result = await showTallyEditorDialog(
      context: context,
      dbTally: counter,
    );
    if (result == null || !context.mounted) return;

    switch (result.action) {
      case EditorActionEnum.edit:
        if (counter.id == (bloc.state as TallyLoadedState).activeCounter?.id &&
            result.value.audioFile != counter.audioFile) {
          await audio.stop();
        }
        bloc.add(TallyEditCounterEvent(counter: result.value));
      case EditorActionEnum.delete:
        final bool? confirm = await showDialog<bool>(
          context: context,
          builder: (_) => YesOrNoDialog(msg: S.of(context).counterWillBeDeleted),
        );
        if (confirm != true) return;
        await audio.stop();
        bloc.add(TallyDeleteCounterEvent(counter: counter));
      default:
    }
  }

  /// Records (or replaces, or removes) the voice of [counter].
  static Future<void> recordVoice(BuildContext context, DbTally counter) async {
    final bloc = context.read<TallyBloc>();
    final audio = context.read<TallyAudioCubit>();
    await audio.stop();
    if (!context.mounted) return;

    final result = await RecordAudioSheet.show(
      context,
      zikrText: counter.title,
      existingFile: counter.hasAudio ? counter.audioFile : null,
    );
    if (result == null) return;
    bloc.add(TallyEditCounterEvent(counter: counter.copyWith(audioFile: result.fileName ?? "")));
  }
}
