import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/src/features/settings/presentation/controller/cubit/settings_cubit.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/presentation/components/zikr_audio_player_bar.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

class ZikrViewerPageModeBottomBar extends StatelessWidget {
  final DbContent dbContent;
  const ZikrViewerPageModeBottomBar({super.key, required this.dbContent});

  @override
  Widget build(BuildContext context) {
    if (dbContent.audio.isNotEmpty) {
      return BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          if (!state.showAudioBar) return const SizedBox.shrink();
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
                    ZikrAudioPlayerBar(dbContent: dbContent),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
    return const SizedBox.shrink();
  }
}
