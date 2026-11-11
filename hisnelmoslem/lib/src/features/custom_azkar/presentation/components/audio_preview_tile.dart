import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/outlined_surface_card.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/data/services/custom_audio_storage.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/bloc/audio_preview/audio_preview_cubit.dart';

/// `mm:ss`
String formatClock(Duration d) {
  String two(int n) => n.toString().padLeft(2, "0");
  return "${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
}

/// Container for one clip of the recording sheet. See [OutlinedSurfaceCard].
class RecordingClipCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const RecordingClipCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedSurfaceCard(padding: padding, child: child);
  }
}

/// Play/pause row with a seek bar for one clip. Give either the name of a [fileName]
/// recording or a bundled [asset]; [previewKey] must be unique among the tiles that
/// share an [AudioPreviewCubit].
class AudioPreviewTile extends StatefulWidget {
  final String previewKey;
  final String label;
  final String? fileName;
  final String? asset;

  /// Small icon before the [label].
  final IconData? icon;

  /// Shown at the end of the row, e.g. a delete button.
  final Widget? trailing;

  const AudioPreviewTile({
    super.key,
    required this.previewKey,
    required this.label,
    this.fileName,
    this.asset,
    this.icon,
    this.trailing,
  }) : assert(fileName != null || asset != null);

  @override
  State<AudioPreviewTile> createState() => _AudioPreviewTileState();
}

class _AudioPreviewTileState extends State<AudioPreviewTile> {
  /// Resolved once, so position updates do not restart it.
  late final Future<String?> _path = widget.fileName == null
      ? Future<String?>.value()
      : sl<CustomAudioStorage>().pathFor(widget.fileName!);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);

    return FutureBuilder<String?>(
      future: _path,
      builder: (context, snapshot) {
        final ready = widget.fileName == null || snapshot.hasData;

        return BlocBuilder<AudioPreviewCubit, AudioPreviewState>(
          builder: (context, state) {
            final active = state.activeKey == widget.previewKey;
            final playing = active && state.isPlaying;
            final max = state.duration.inMilliseconds.toDouble();
            final value = state.position.inMilliseconds.toDouble().clamp(0.0, max);

            return Row(
              children: [
                IconButton.filled(
                  tooltip: playing ? s.recordPause : s.recordPlay,
                  iconSize: 28,
                  onPressed: ready
                      ? () => context.read<AudioPreviewCubit>().toggle(
                          widget.previewKey,
                          filePath: snapshot.data,
                          asset: widget.asset,
                        )
                      : null,
                  icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, size: 18, color: theme.colorScheme.primary),
                            const SizedBox(width: 6),
                          ],
                          Expanded(
                            child: Text(
                              widget.label,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (active && max > 0)
                        Row(
                          children: [
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 2,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                                ),
                                child: Slider(
                                  max: max,
                                  value: value,
                                  onChanged: (v) => context.read<AudioPreviewCubit>().seek(
                                    Duration(milliseconds: v.toInt()),
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              "${formatClock(state.position)} / ${formatClock(state.duration)}",
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                if (widget.trailing != null) widget.trailing!,
              ],
            );
          },
        );
      },
    );
  }
}
