import 'package:flutter/material.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/presentation/components/zikr_audio_player_bar.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

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
          if (dbContent.audio.isNotEmpty) ZikrAudioPlayerBar(dbContent: dbContent),
          // const Padding(
          //   padding: EdgeInsets.symmetric(horizontal: 10),
          //   child: NavigationSlider(),
          // ),
        ],
      ),
    );
  }
}
