import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/presentation/components/zikr_audio_settings_dialog.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/presentation/controller/cubit/zikr_audio_player_cubit.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/controller/bloc/zikr_viewer_bloc.dart';

class ZikrAudioPlayerBar extends StatelessWidget {
  final DbContent dbContent;
  const ZikrAudioPlayerBar({super.key, required this.dbContent});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ZikrAudioPlayerCubit, ZikrAudioPlayerState>(
      builder: (context, state) {
        final cubit = context.read<ZikrAudioPlayerCubit>();
        final position = state.position;
        final duration = state.totalDuration;

        final double maxDuration = duration.inMilliseconds.toDouble();
        final double sliderValue = position.inMilliseconds.toDouble().clamp(0.0, maxDuration);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1: Slider + time label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 2.0,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
                      ),
                      child: Slider(
                        max: maxDuration > 0 ? maxDuration : 1.0,
                        value: maxDuration > 0 ? sliderValue : 0.0,
                        onChanged: (value) {
                          cubit.seek(Duration(milliseconds: value.toInt()));
                        },
                      ),
                    ),
                  ),
                  Text(
                    "${_formatDuration(position)} / ${_formatDuration(duration)}",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            // Row 2: Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(onPressed: cubit.stop, icon: const Icon(Icons.stop)),
                IconButton(
                  iconSize: 36,
                  onPressed: () {
                    if (state.isPlaying) {
                      cubit.pause();
                    } else if (state.isPaused && state.position > Duration.zero) {
                      cubit.resume();
                    } else {
                      final activeIndex =
                          context.read<ZikrViewerBloc>().state is ZikrViewerLoadedState
                          ? (context.read<ZikrViewerBloc>().state as ZikrViewerLoadedState)
                                .activeZikrIndex
                          : 0;
                      cubit.startPlayFromIndex(activeIndex);
                    }
                  },
                  icon: Icon(
                    state.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => const SafeArea(child: ZikrAudioSettingsDialog()),
                    );
                  },
                  icon: const Icon(Icons.settings),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
