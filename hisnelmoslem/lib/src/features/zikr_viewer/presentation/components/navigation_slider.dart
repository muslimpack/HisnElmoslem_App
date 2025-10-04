import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/controller/bloc/zikr_viewer_bloc.dart';

class NavigationSlider extends StatelessWidget {
  const NavigationSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ZikrViewerBloc, ZikrViewerState>(
      builder: (context, state) {
        if (state is! ZikrViewerLoadedState) {
          return const SizedBox();
        }

        return Row(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 20),
              child: Text("${state.activeZikrIndex + 1}"),
            ),
            Expanded(
              child: Slider(
                divisions: state.azkarToView.length - 1,
                label: "${state.activeZikrIndex + 1}",
                secondaryTrackValue: state.activeZikrIndex.toDouble(),
                max: (state.azkarToView.length - 1).toDouble(),
                value: state.activeZikrIndex.toDouble(),
                onChanged: (value) {
                  context.read<ZikrViewerBloc>().pageController.jumpToPage(value.toInt());
                },
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 20),
              child: Text("${state.azkarToView.length}"),
            ),
          ],
        );
      },
    );
  }
}
