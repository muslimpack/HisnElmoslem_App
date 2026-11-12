import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_object.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally_session_limit.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/components/sheets/tally_more_sheet.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/components/sheets/tally_session_sheet.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/components/tally_actions.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/components/tally_dock_counter.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/controller/bloc/tally_bloc.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/controller/cubit/tally_audio_cubit.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/zikr_viewer_bottom_dock.dart';

/// The dock of the counter, laid out like the one of the zikr viewer: the voice session
/// at one end, the count in the middle and the options at the other end. The seek bar
/// of the recording only takes room while it plays.
class TallyCounterViewBottomBar extends StatelessWidget {
  const TallyCounterViewBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final counter = context.select<TallyBloc, DbTally?>((bloc) {
      final state = bloc.state;
      return state is TallyLoadedState ? state.activeCounter : null;
    });
    if (counter == null) return const SizedBox.shrink();

    return Material(
      color: theme.colorScheme.surfaceContainer,
      elevation: 8,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (counter.hasAudio)
                BlocProvider.value(
                  value: context.read<TallyAudioCubit>().engine,
                  child: const DockAudioProgress(),
                ),
              Row(
                children: [
                  Expanded(
                    child: Align(
                      child: TallySessionTile(counter: counter),
                    ),
                  ),
                  TallyDockCounter(counter: counter),
                  Expanded(
                    child: Align(
                      child: TallyDockTile(
                        icon: Icons.tune_rounded,
                        label: S.of(context).zikrOptions,
                        onTap: () => TallyMoreSheet.show(context),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A round icon with its name under it. The whole tile is tappable.
class TallyDockTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const TallyDockTile({super.key, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: label,
      // Without this the tile can be focused but not activated: excluding the children
      // also drops the tap action of the InkWell.
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: theme.colorScheme.primary.withAlpha(30),
                foregroundColor: theme.colorScheme.primary,
                child: Icon(icon),
              ),
              // As tall as the limit chip of the session tile, so both labels line up.
              SizedBox(
                height: 48,
                child: Center(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The voice: play / pause (and stop while it runs) with the limit of the session under
/// it, or a way to record one when the counter has none. Tapping the limit changes it.
class TallySessionTile extends StatelessWidget {
  final DbTally counter;

  const TallySessionTile({super.key, required this.counter});

  static String limitLabel(BuildContext context, TallySessionLimit limit) {
    final s = S.of(context);
    return switch (limit.type) {
      TallySessionLimitType.endless => s.tallySessionEndlessShort,
      TallySessionLimitType.minutes => s.tallyMinutesShort(limit.value).toArabicNumber(),
      TallySessionLimitType.count => '${limit.value}'.toArabicNumber(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    if (!counter.hasAudio) {
      return TallyDockTile(
        icon: Icons.mic_rounded,
        label: s.recordVoice,
        onTap: () => TallyActions.recordVoice(context, counter),
      );
    }

    return BlocBuilder<TallyAudioCubit, TallyAudioState>(
      builder: (context, state) {
        final audio = context.read<TallyAudioCubit>();
        final playing = state.phase == TallyAudioPhase.playing;
        final limit = state.limit;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [
                if (state.isActive)
                  IconButton.outlined(
                    tooltip: s.audioStop,
                    onPressed: audio.stop,
                    icon: const Icon(Icons.stop_rounded),
                  ),
                IconButton.filledTonal(
                  tooltip: playing ? s.audioPause : s.audioPlay,
                  iconSize: 30,
                  constraints: const BoxConstraints.tightFor(width: 52, height: 52),
                  onPressed: () {
                    if (playing) {
                      audio.pause();
                    } else if (state.phase == TallyAudioPhase.paused) {
                      audio.resume();
                    } else {
                      audio.start();
                    }
                  },
                  icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
                ),
              ],
            ),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => TallySessionSheet.show(context),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      Icon(
                        switch (limit.type) {
                          TallySessionLimitType.minutes => Icons.timer_outlined,
                          TallySessionLimitType.count => Icons.tag_rounded,
                          TallySessionLimitType.endless => Icons.all_inclusive_rounded,
                        },
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      Text(limitLabel(context, limit), style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
