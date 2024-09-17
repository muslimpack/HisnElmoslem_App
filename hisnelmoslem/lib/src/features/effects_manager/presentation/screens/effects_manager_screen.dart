import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
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
              "effect manager".tr,
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
                title: Text("Sound Effect volume".tr),
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
                  title: Text("sound effect at every praise".tr),
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
                  title: Text("sound effect at single zikr end".tr),
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
                  title: Text("sound effect when all zikr end".tr),
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
                  title: Text("phone vibration at every praise".tr),
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
                  title: Text("phone vibration at single zikr end".tr),
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
                  title: Text("phone vibration when all zikr end".tr),
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
