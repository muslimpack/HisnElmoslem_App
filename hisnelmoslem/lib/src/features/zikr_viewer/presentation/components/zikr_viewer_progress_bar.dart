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

        return Stack(
          children: [
            LinearProgressIndicator(
              value: 1 - state.manorProgress,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              value: state.majorProgress,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(
                  context,
                ).colorScheme.primary.withAlpha((.5 * 255).round()),
              ),
            ),
          ],
        );
      },
    );
  }
}
