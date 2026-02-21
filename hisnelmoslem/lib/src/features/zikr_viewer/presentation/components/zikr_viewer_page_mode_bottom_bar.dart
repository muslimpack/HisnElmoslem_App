import 'package:flutter/material.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/presentation/components/zikr_audio_player_bar.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

class ZikrViewerPageModeBottomBar extends StatelessWidget {
  final DbContent dbContent;
  const ZikrViewerPageModeBottomBar({super.key, required this.dbContent});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8).copyWith(top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (dbContent.audio.isNotEmpty) ZikrAudioPlayerBar(dbContent: dbContent),
            ],
          ),
        ),
      ),
    );
  }
}
