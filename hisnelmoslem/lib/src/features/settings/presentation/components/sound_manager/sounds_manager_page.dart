import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/settings/presentation/components/sound_manager/sounds_manager_controller.dart';

class SoundsManagerPage extends StatelessWidget {
  const SoundsManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SoundsManagerController>(
      init: SoundsManagerController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              S.of(context).effect_manager,
              style: const TextStyle(fontFamily: "Uthmanic"),
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
                title: Text(S.of(context).sound_effect_volume),
                subtitle: Slider(
                  value: controller.soundEffectVolume,
                  onChanged: (value) {
                    controller.changeSoundEffectVolume(value);
                    controller.update();
                  },
                ),
              ),

              const Divider(),

              /// Tally Sound Allowed Vibrate
              SwitchListTile(
                title: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.vibration,
                  ),
                  title: Text(
                    S.of(context).phone_vibration_at_every_praise,
                  ),
                ),
                activeColor: mainColor,
                value: controller.isTallyVibrateAllowed,
                onChanged: (value) {
                  controller.changeTallyVibrateStatus(value: value);

                  if (value) {
                    controller.simulateTallyVibrate();
                  }

                  controller.update();
                },
              ),

              /// Tally Sound Allowed
              SwitchListTile(
                title: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.speaker,
                  ),
                  title: Text(
                    S.of(context).sound_effect_at_every_praise,
                  ),
                ),
                activeColor: mainColor,
                value: controller.isTallySoundAllowed,
                onChanged: (value) {
                  controller.changeTallySoundStatus(value: value);

                  if (value) {
                    controller.simulateTallySound();
                  }

                  controller.update();
                },
              ),

              /// Zikr Done Sound Allowed Vibrate
              SwitchListTile(
                title: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.vibration,
                  ),
                  title: Text(
                    S.of(context).phone_vibration_at_single_zikr_end,
                  ),
                ),
                activeColor: mainColor,
                value: controller.isZikrDoneVibrateAllowed,
                onChanged: (value) {
                  controller.changeZikrDoneVibrateStatus(value: value);

                  if (value) {
                    controller.simulateZikrDoneVibrate();
                  }
                  controller.update();
                },
              ),

              /// Zikr Done Sound Allowed
              SwitchListTile(
                title: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.speaker,
                  ),
                  title: Text(
                    S.of(context).sound_effect_at_single_zikr_end,
                  ),
                ),
                activeColor: mainColor,
                value: controller.isZikrDoneSoundAllowed,
                onChanged: (value) {
                  controller.changeZikrDoneSoundStatus(value: value);

                  if (value) {
                    controller.simulateZikrDoneSound();
                  }
                  controller.update();
                },
              ),

              /// Azkar Done Sound Allowed vibrate
              SwitchListTile(
                title: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.vibration,
                  ),
                  title: Text(
                    S.of(context).phone_vibration_when_all_zikr_end,
                  ),
                ),
                activeColor: mainColor,
                value: controller.isAllAzkarFinishedVibrateAllowed,
                onChanged: (value) {
                  controller.changeAllAzkarFinishedVibrateStatus(
                    value: value,
                  );

                  if (value) {
                    controller.simulateAllAzkarVibrateFinished();
                  }
                  controller.update();
                },
              ),

              /// Azkar Done Sound Allowed
              SwitchListTile(
                title: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.speaker,
                  ),
                  title: Text(
                    S.of(context).sound_effect_when_all_zikr_end,
                  ),
                ),
                activeColor: mainColor,
                value: controller.isAllAzkarFinishedSoundAllowed,
                onChanged: (value) {
                  controller.changeAllAzkarFinishedSoundStatus(value: value);

                  if (value) {
                    controller.simulateAllAzkarSoundFinished();
                  }
                  controller.update();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
