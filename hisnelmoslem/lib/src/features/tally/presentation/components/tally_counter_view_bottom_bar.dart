import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_object.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally_session_limit.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/components/sheets/tally_more_sheet.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/components/sheets/tally_session_sheet.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/components/tally_actions.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/controller/bloc/tally_bloc.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/controller/cubit/tally_audio_cubit.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/presentation/controller/cubit/zikr_audio_player_cubit.dart';

/// Bottom panel of the counter: undo one count, the voice (play, or record when the
/// counter has none) and the other options. Reset is not here, so it cannot be hit by
/// accident while counting.
class TallyCounterViewBottomBar extends StatelessWidget {
  const TallyCounterViewBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final counter = context.select<TallyBloc, DbTally?>(
      (bloc) =>
          bloc.state is TallyLoadedState ? (bloc.state as TallyLoadedState).activeCounter : null,
    );
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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (counter.hasAudio) const TallyVoiceStatus(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TallyDockButton(
                        icon: Icons.remove_rounded,
                        label: S.of(context).decrease,
                        onPressed: () => TallyActions.decrease(context),
                      ),
                    ),
                  ),
                  TallyVoiceButton(counter: counter),
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TallyDockButton(
                        icon: Icons.more_horiz_rounded,
                        label: S.of(context).tallyMoreOptions,
                        onPressed: () => TallyMoreSheet.show(context),
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

/// A round tonal button with its name under it (at least 48 dp to tap).
class TallyDockButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const TallyDockButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 96),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton.filledTonal(
            tooltip: label,
            iconSize: 28,
            constraints: const BoxConstraints.tightFor(width: 56, height: 56),
            onPressed: onPressed,
            icon: Icon(icon),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

/// Play / pause / stop of the voice, or a button to record one.
class TallyVoiceButton extends StatelessWidget {
  final DbTally counter;

  const TallyVoiceButton({super.key, required this.counter});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    if (!counter.hasAudio) {
      return Flexible(
        flex: 2,
        child: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: FilledButton.tonalIcon(
            onPressed: () => TallyActions.recordVoice(context, counter),
            icon: const Icon(Icons.mic_rounded),
            label: Text(s.recordVoice, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
      );
    }

    return BlocBuilder<TallyAudioCubit, TallyAudioState>(
      builder: (context, state) {
        final audio = context.read<TallyAudioCubit>();
        final playing = state.phase == TallyAudioPhase.playing;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state.isActive)
              IconButton(
                tooltip: s.audioStop,
                iconSize: 28,
                onPressed: audio.stop,
                icon: const Icon(Icons.stop_rounded),
              ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton.filled(
                  tooltip: playing ? s.audioPause : s.audioPlay,
                  iconSize: 36,
                  constraints: const BoxConstraints.tightFor(width: 64, height: 64),
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
                const SizedBox(height: 4),
                Text(
                  playing ? s.audioPause : s.audioPlay,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// How long the playback goes on (tap to change), what it has counted and how far the
/// current recording is.
class TallyVoiceStatus extends StatelessWidget {
  const TallyVoiceStatus({super.key});

  static String limitLabel(BuildContext context, TallySessionLimit limit) {
    return switch (limit.type) {
      TallySessionLimitType.endless => '∞',
      TallySessionLimitType.minutes => S.of(context).tallyMinutesShort(limit.value),
      TallySessionLimitType.count => '${limit.value}'.toArabicNumber(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<TallyAudioCubit, TallyAudioState>(
      builder: (context, state) {
        final engine = context.read<TallyAudioCubit>().engine;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            children: [
              Row(
                children: [
                  ActionChip(
                    avatar: Icon(
                      state.limit.type == TallySessionLimitType.minutes
                          ? Icons.timer_outlined
                          : state.limit.type == TallySessionLimitType.count
                          ? Icons.tag_rounded
                          : Icons.all_inclusive_rounded,
                      size: 18,
                    ),
                    label: Text(limitLabel(context, state.limit).toArabicNumber()),
                    tooltip: S.of(context).tallySession,
                    onPressed: () => TallySessionSheet.show(context),
                  ),
                  const Spacer(),
                  if (state.isActive)
                    Text(
                      S.of(context).tallySessionCounted(state.sessionCount).toArabicNumber(),
                      style: theme.textTheme.labelLarge,
                    ),
                ],
              ),
              if (state.isActive)
                BlocBuilder<ZikrAudioPlayerCubit, ZikrAudioPlayerState>(
                  bloc: engine,
                  buildWhen: (a, b) =>
                      a.position != b.position || a.totalDuration != b.totalDuration,
                  builder: (context, audio) {
                    final total = audio.totalDuration.inMilliseconds;
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: LinearProgressIndicator(
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                        value: total == 0
                            ? 0
                            : (audio.position.inMilliseconds / total).clamp(0.0, 1.0),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
