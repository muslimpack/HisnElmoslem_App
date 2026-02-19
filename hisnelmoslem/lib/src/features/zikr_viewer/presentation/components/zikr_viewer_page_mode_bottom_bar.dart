import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/navigation_slider.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/controller/bloc/zikr_viewer_bloc.dart';

class ZikrViewerPageModeBottomBar extends StatelessWidget {
  final DbContent dbContent;
  const ZikrViewerPageModeBottomBar({super.key, required this.dbContent});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (dbContent.audio.isNotEmpty)
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    context.read<ZikrViewerBloc>().zikrAudioPlayerCubit.playAll();
                  },
                  icon: const Icon(Icons.play_arrow),
                ),
                IconButton(
                  onPressed: () {
                    context.read<ZikrViewerBloc>().zikrAudioPlayerCubit.stop();
                  },
                  icon: const Icon(Icons.stop),
                ),
              ],
            ),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: NavigationSlider()),
        ],
      ),
    );
  }
}
