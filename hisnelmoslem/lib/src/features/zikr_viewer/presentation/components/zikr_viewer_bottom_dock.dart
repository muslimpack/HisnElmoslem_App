import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_object.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/dock_row.dart';
import 'package:hisnelmoslem/src/features/settings/presentation/controller/cubit/settings_cubit.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/presentation/controller/cubit/zikr_audio_player_cubit.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/zikr_action_tile.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/zikr_actions_sheet.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/controller/bloc/zikr_viewer_bloc.dart';

/// Bottom panel of the page-mode viewer: the options button, the remaining count as a
/// large tap target with a progress ring, and the controls of the zikr's audio.
class ZikrViewerBottomDock extends StatelessWidget {
  final DbContent dbContent;
  const ZikrViewerBottomDock({super.key, required this.dbContent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showAudio =
        dbContent.hasPlayableAudio &&
        context.select<SettingsCubit, bool>((cubit) => cubit.state.showAudioBar);

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
              if (showAudio) const DockAudioProgress(),
              DockRow(
                play: showAudio ? const DockAudioControls() : const SizedBox.shrink(),
                counter: DockCounter(dbContent: dbContent),
                options: ZikrActionTile(
                  icon: Icons.tune_rounded,
                  label: S.of(context).zikrOptions,
                  onTap: () => ZikrActionsSheet.show(context, dbContent: dbContent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Remaining count inside a ring that fills as the zikr is recited. Tapping counts.
class DockCounter extends StatelessWidget {
  final DbContent dbContent;
  const DockCounter({super.key, required this.dbContent});

  static const double _size = 84;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    final state = context.watch<ZikrViewerBloc>().state;

    // The count the zikr started with, to know how much of it is done.
    final initial = state is ZikrViewerLoadedState
        ? state.azkar.where((e) => e.id == dbContent.id).map((e) => e.count).firstOrNull
        : null;
    final total = max(1, max(initial ?? 1, dbContent.count));
    final isDone = dbContent.count == 0;
    final progress = isDone ? 1.0 : (total - dbContent.count) / total;

    return Semantics(
      button: true,
      label: isDone ? s.zikrDone : s.zikrTapToCount,
      child: SizedBox(
        width: _size,
        height: _size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(end: progress),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              builder: (context, value, _) => CircularProgressIndicator(
                value: value,
                strokeWidth: 6,
                strokeCap: StrokeCap.round,
                backgroundColor: theme.colorScheme.primary.withAlpha(40),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(9),
              child: Material(
                color: isDone ? theme.colorScheme.primary : theme.colorScheme.primaryContainer,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: isDone
                      ? null
                      : () => context.read<ZikrViewerBloc>().add(
                          ZikrViewerDecreaseZikrEvent(content: dbContent),
                        ),
                  child: Center(
                    child: isDone
                        ? Icon(Icons.check_rounded, size: 34, color: theme.colorScheme.onPrimary)
                        : AnimatedSwitcher(
                            duration: const Duration(milliseconds: 150),
                            child: Text(
                              dbContent.count.toArabicNumber(),
                              key: ValueKey<int>(dbContent.count),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimaryContainer,
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

/// Seek bar with times; only takes space while audio is playing or paused mid-way.
class DockAudioProgress extends StatelessWidget {
  const DockAudioProgress({super.key});

  String _clock(Duration d) {
    String two(int n) => n.toString().padLeft(2, "0");
    return "${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ZikrAudioPlayerCubit, ZikrAudioPlayerState>(
      builder: (context, state) {
        final active = state.isPlaying || (state.isPaused && state.position > Duration.zero);
        final max = state.totalDuration.inMilliseconds.toDouble();
        final value = state.position.inMilliseconds.toDouble().clamp(0.0, max);

        return AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: active && max > 0
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text(_clock(state.position), style: theme.textTheme.bodySmall),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                          ),
                          child: Slider(
                            max: max,
                            value: value,
                            onChanged: (v) => context.read<ZikrAudioPlayerCubit>().seek(
                              Duration(milliseconds: v.toInt()),
                            ),
                          ),
                        ),
                      ),
                      Text(_clock(state.totalDuration), style: theme.textTheme.bodySmall),
                    ],
                  ),
                )
              : const SizedBox(width: double.infinity),
        );
      },
    );
  }
}

/// Play / pause, and stop while active. Audio settings are in the options sheet: three
/// buttons do not fit next to the counter on a narrow phone.
class DockAudioControls extends StatelessWidget {
  const DockAudioControls({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocBuilder<ZikrAudioPlayerCubit, ZikrAudioPlayerState>(
      builder: (context, state) {
        final cubit = context.read<ZikrAudioPlayerCubit>();
        final active = state.isPlaying || (state.isPaused && state.position > Duration.zero);

        return Row(
          mainAxisSize: MainAxisSize.min,
          // Play first (on the left), then stop, in both directions.
          textDirection: TextDirection.ltr,
          children: [
            IconButton.filledTonal(
              tooltip: state.isPlaying ? s.audioPause : s.audioPlay,
              iconSize: 30,
              padding: const EdgeInsets.all(12),
              onPressed: () {
                if (state.isPlaying) {
                  cubit.pause();
                } else if (state.isPaused && state.position > Duration.zero) {
                  cubit.resume();
                } else {
                  final viewer = context.read<ZikrViewerBloc>().state;
                  cubit.startPlayFromIndex(
                    viewer is ZikrViewerLoadedState ? viewer.activeZikrIndex : 0,
                  );
                }
              },
              icon: Icon(state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
            ),
            if (active)
              IconButton(
                tooltip: s.audioStop,
                onPressed: cubit.stop,
                icon: const Icon(Icons.stop_rounded),
              ),
          ],
        );
      },
    );
  }
}
