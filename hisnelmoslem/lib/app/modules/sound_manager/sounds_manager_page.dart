import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/app/modules/sound_manager/sounds_manager_controller.dart';
import 'package:hisnelmoslem/app/shared/widgets/scroll_glow_custom.dart';
import 'package:hisnelmoslem/core/values/constant.dart';

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
              "effect manager".tr,
              style: const TextStyle(fontFamily: "Uthmanic"),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
          ),
          body: ScrollGlowCustom(
            child: ListView(
              physics: const ClampingScrollPhysics(),
              children: [
                /// Transition Sound Allowed
                // SwitchListTile(
                //   title: ListTile(
                //     contentPadding: EdgeInsets.all(0),
                //     leading: Icon(
                //       Icons.speaker,
                //     ),
                //     title: Text("صوت عند الانتقال بين الصفحات"),
                //   ),
                //   activeColor: mainColor,
                //   value: controller.isTransitionSoundAllowed,
                //   onChanged: (value) {
                //     controller.changeTransitionSoundStatus(value);

                //     if (value) {
                //       controller.playTransitionSound();
                //     } else {
                //       // getSnackbar(
                //       //     message: "الغاء تفعيل منبه صيام الإثنين والخميس");
                //     }
                //     controller.update();
                //   },
                // ),
                ListTile(
                  leading: const Icon(
                    Icons.volume_up,
                  ),
                  title: Text("Sound Effect volume".tr),
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
                    title: Text("phone vibration at every praise".tr),
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
                    title: Text("sound effect at every praise".tr),
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
                    title: Text("phone vibration at single zikr end".tr),
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
                    title: Text("sound effect at single zikr end".tr),
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
                    title: Text("phone vibration when all zikr end".tr),
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
                    title: Text("sound effect when all zikr end".tr),
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
          ),
        );
      },
    );
  }
}
