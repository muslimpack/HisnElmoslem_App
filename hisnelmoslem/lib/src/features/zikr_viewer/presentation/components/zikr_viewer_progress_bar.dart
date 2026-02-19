import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/controller/bloc/zikr_viewer_bloc.dart';

class ZikrViewerProgressBar extends StatelessWidget {
  const ZikrViewerProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ZikrViewerBloc, ZikrViewerState>(
      builder: (context, state) {
        if (state is! ZikrViewerLoadedState) {
          return const SizedBox();
        }

        return AnimatedDualProgressBar(
          minorProgress: state.manorProgress,
          majorProgress: state.majorProgress,
        );
      },
    );
  }
}

class AnimatedDualProgressBar extends StatelessWidget {
  final double majorProgress;
  final double minorProgress;

  const AnimatedDualProgressBar({
    super.key,
    required this.majorProgress,
    required this.minorProgress,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: 6,
      child: Stack(
        children: [
          // Minor progress (back layer)
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1 - minorProgress),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                valueColor: AlwaysStoppedAnimation<Color>(color.withAlpha((0.5 * 255).toInt())),
              );
            },
          ),

          // Major progress (front layer)
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: majorProgress),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(color.withAlpha((0.5 * 255).toInt())),
              );
            },
          ),
        ],
      ),
    );
  }
}
