import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/settings/presentation/controller/cubit/settings_cubit.dart';

class EffectsManagerScreen extends StatelessWidget {
  const EffectsManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              S.of(context).effectManager,
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              ListTile(
                leading: const Icon(
                  Icons.volume_up,
                ),
                title: Text(S.of(context).soundEffectVolume),
                subtitle: Slider(
                  value: state.zikrEffects.soundEffectVolume,
                  onChanged: (value) {
                    context.read<SettingsCubit>().zikrEffectChangeVolume(value);
                  },
                ),
              ),

              /// Tally Sound Allowed
              SwitchListTile(
                title: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.speaker,
                  ),
                  title: Text(S.of(context).soundEffectAtEveryPraise),
                ),
                value: state.zikrEffects.soundEveryPraise,
                onChanged: (value) {
                  context
                      .read<SettingsCubit>()
                      .zikrEffectChangePlaySoundEveryPraise(activate: value);
                },
              ),

              /// Zikr Done Sound Allowed
              SwitchListTile(
                title: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.speaker,
                  ),
                  title: Text(S.of(context).soundEffectAtSingleZikrEnd),
                ),
                value: state.zikrEffects.soundEveryZikr,
                onChanged: (value) {
                  context
                      .read<SettingsCubit>()
                      .zikrEffectChangePlaySoundEveryZikr(activate: value);
                },
              ),

              /// Azkar Done Sound Allowed
              SwitchListTile(
                title: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.speaker,
                  ),
                  title: Text(S.of(context).soundEffectWhenAllZikrEnd),
                ),
                value: state.zikrEffects.soundEveryTitle,
                onChanged: (value) {
                  context
                      .read<SettingsCubit>()
                      .zikrEffectChangePlaySoundEveryTitle(activate: value);
                },
              ),
              const Divider(),

              /// Tally Sound Allowed Vibrate
              SwitchListTile(
                title: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.vibration,
                  ),
                  title: Text(S.of(context).phoneVibrationAtEveryPraise),
                ),
                value: state.zikrEffects.vibrateEveryPraise,
                onChanged: (value) {
                  context
                      .read<SettingsCubit>()
                      .zikrEffectChangePlayVibrationEveryPraise(
                        activate: value,
                      );
                },
              ),

              /// Zikr Done Sound Allowed Vibrate
              SwitchListTile(
                title: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.vibration,
                  ),
                  title: Text(S.of(context).phoneVibrationAtSingleZikrEnd),
                ),
                value: state.zikrEffects.vibrateEveryZikr,
                onChanged: (value) {
                  context
                      .read<SettingsCubit>()
                      .zikrEffectChangePlayVibrationEveryZikr(activate: value);
                },
              ),

              /// Azkar Done Sound Allowed vibrate
              SwitchListTile(
                title: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.vibration,
                  ),
                  title: Text(S.of(context).phoneVibrationWhenAllZikrEnd),
                ),
                value: state.zikrEffects.vibrateEveryTitle,
                onChanged: (value) {
                  context
                      .read<SettingsCubit>()
                      .zikrEffectChangePlayVibrationEveryTitle(activate: value);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
