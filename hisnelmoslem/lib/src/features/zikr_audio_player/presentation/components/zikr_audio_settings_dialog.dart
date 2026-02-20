import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/data/models/audio_delay_type_enum.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/presentation/controller/cubit/zikr_audio_player_cubit.dart';

class ZikrAudioSettingsDialog extends StatelessWidget {
  const ZikrAudioSettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ZikrAudioPlayerCubit, ZikrAudioPlayerState>(
      builder: (context, state) {
        final cubit = context.read<ZikrAudioPlayerCubit>();
        return Padding(
          padding: const EdgeInsets.all(
            16.0,
          ).copyWith(bottom: MediaQuery.of(context).viewInsets.bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                S.of(context).audioPlayerSettings,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _buildSpeedSlider(context, state, cubit),
              const SizedBox(height: 16),
              _buildVolumeSlider(context, state, cubit),
              const SizedBox(height: 16),
              _buildDelaySettings(context, state, cubit),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpeedSlider(
    BuildContext context,
    ZikrAudioPlayerState state,
    ZikrAudioPlayerCubit cubit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${S.of(context).audioPlayerSpeed} (${state.playbackSpeed.toStringAsFixed(1)}x)",
        ),
        Slider(
          value: state.playbackSpeed,
          min: 0.5,
          max: 2.0,
          divisions: 15,
          onChanged: (val) {
            cubit.saveSettings(speed: val);
          },
        ),
      ],
    );
  }

  Widget _buildVolumeSlider(
    BuildContext context,
    ZikrAudioPlayerState state,
    ZikrAudioPlayerCubit cubit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${S.of(context).audioPlayerVolume} (${(state.volume * 100).toInt()}%)",
        ),
        Slider(
          value: state.volume,
          divisions: 20,
          onChanged: (val) {
            cubit.saveSettings(volume: val);
          },
        ),
      ],
    );
  }

  Widget _buildDelaySettings(
    BuildContext context,
    ZikrAudioPlayerState state,
    ZikrAudioPlayerCubit cubit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(S.of(context).audioPlayerDelay),
        DropdownButton<AudioDelayTypeEnum>(
          isExpanded: true,
          value: state.delayType,
          items: [
            DropdownMenuItem(
              value: AudioDelayTypeEnum.none,
              child: Text(S.of(context).audioPlayerDelayNone),
            ),
            DropdownMenuItem(
              value: AudioDelayTypeEnum.byPreviousZikr,
              child: Text(S.of(context).audioPlayerDelayByPrevious),
            ),
            DropdownMenuItem(
              value: AudioDelayTypeEnum.fixedTime,
              child: Text(S.of(context).audioPlayerDelayFixed),
            ),
          ],
          onChanged: (val) {
            if (val != null) {
              cubit.saveSettings(delayType: val);
            }
          },
        ),
        if (state.delayType == AudioDelayTypeEnum.fixedTime)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Slider(
                    value: state.delayDuration.toDouble(),
                    min: 1.0,
                    max: 15.0,
                    divisions: 14,
                    onChanged: (val) {
                      cubit.saveSettings(delayDuration: val.toInt());
                    },
                  ),
                ),
                Text(
                  "${state.delayDuration} ${S.of(context).audioPlayerDelaySeconds}",
                ),
              ],
            ),
          ),
      ],
    );
  }
}
