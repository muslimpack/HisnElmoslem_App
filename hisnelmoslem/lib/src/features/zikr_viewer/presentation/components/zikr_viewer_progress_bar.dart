import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_viewer_mode.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/controller/bloc/zikr_viewer_bloc.dart';

/// Stories-style progress: one segment per zikr, each filling as that zikr's own count is
/// finished. In page mode the active zikr's segment is taller.
class ZikrViewerProgressBar extends StatelessWidget {
  const ZikrViewerProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ZikrViewerBloc, ZikrViewerState>(
      builder: (context, state) {
        if (state is! ZikrViewerLoadedState) return const SizedBox();

        final originalCounts = {for (final z in state.azkar) z.id: z.count};
        final progress = [
          for (final z in state.azkarToView)
            _zikrProgress(z.count, originalCounts[z.id] ?? z.count),
        ];
        final activeIndex = state.zikrViewerMode == ZikrViewerMode.page
            ? state.activeZikrIndex
            : -1;

        return SegmentedProgressBar(progress: progress, activeIndex: activeIndex);
      },
    );
  }

  /// 0 when untouched, 1 when the remaining count reached zero.
  static double _zikrProgress(int remaining, int original) {
    if (original <= 0) return 1;
    return (1 - remaining / original).clamp(0.0, 1.0);
  }
}

class SegmentedProgressBar extends StatelessWidget {
  static const double _gap = 3;
  static const double _minSegmentWidth = 5;
  static const double _height = 4;
  static const double _activeHeight = 7;
  static const Duration _duration = Duration(milliseconds: 400);

  /// Fill of every segment, 0..1.
  final List<double> progress;

  /// Segment drawn taller, or -1 for none.
  final int activeIndex;

  const SegmentedProgressBar({super.key, required this.progress, this.activeIndex = -1});

  @override
  Widget build(BuildContext context) {
    if (progress.isEmpty) return const SizedBox();

    final scheme = Theme.of(context).colorScheme;
    final fill = scheme.primary;
    final track = scheme.primary.withValues(alpha: 0.25);

    return SizedBox(
      height: _activeHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth =
              (constraints.maxWidth - _gap * (progress.length - 1)) / progress.length;

          // Too many zikrs for readable segments: one continuous bar of the total.
          if (segmentWidth < _minSegmentWidth) {
            final total = progress.fold<double>(0, (a, b) => a + b) / progress.length;
            return Align(
              child: _Segment(
                value: total,
                height: _height,
                fill: fill,
                track: track,
                duration: _duration,
              ),
            );
          }

          return Row(
            spacing: _gap,
            children: [
              for (var i = 0; i < progress.length; i++)
                Expanded(
                  child: Align(
                    child: _Segment(
                      value: progress[i],
                      height: i == activeIndex ? _activeHeight : _height,
                      fill: fill,
                      track: track,
                      duration: _duration,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.value,
    required this.height,
    required this.fill,
    required this.track,
    required this.duration,
  });

  final double value;
  final double height;
  final Color fill;
  final Color track;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration,
      height: height,
      decoration: BoxDecoration(color: track, borderRadius: BorderRadius.circular(height)),
      clipBehavior: Clip.antiAlias,
      alignment: AlignmentDirectional.centerStart,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: value),
        duration: duration,
        curve: Curves.easeInOut,
        builder: (context, v, _) => FractionallySizedBox(
          widthFactor: v,
          heightFactor: 1,
          child: ColoredBox(color: fill),
        ),
      ),
    );
  }
}
