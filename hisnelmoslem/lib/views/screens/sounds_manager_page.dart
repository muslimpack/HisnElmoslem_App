import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:hisnelmoslem/controllers/sounds_manager_controller.dart';
import 'package:hisnelmoslem/shared/widgets/scroll_glow_custom.dart';

import '../../shared/constants/constant.dart';

class SoundsManagerPage extends StatelessWidget {
  const SoundsManagerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SoundsManagerController>(
        init: SoundsManagerController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text("إدارة مؤثرات الصوت",
                  style: TextStyle(fontFamily: "Uthmanic")),
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
                  //       //     message: "تم الغاء منبه صيام الإثنين والخميس");
                  //     }
                  //     controller.update();
                  //   },
                  // ),

                  /// Tally Sound Allowed
                  SwitchListTile(
                    title: const ListTile(
                      contentPadding: EdgeInsets.all(0),
                      leading: Icon(
                        Icons.speaker,
                      ),
                      title: Text("اشعار عند كل تسبيحة"),
                    ),
                    activeColor: mainColor,
                    value: controller.isTallySoundAllowed,
                    onChanged: (value) {
                      controller.changeTallySoundStatus(value);

                      if (value) {
                        controller.playTallySound();
                      }

                      controller.update();
                    },
                  ),

                  /// Zikr Done Sound Allowed
                  SwitchListTile(
                    title: const ListTile(
                      contentPadding: EdgeInsets.all(0),
                      leading: Icon(
                        Icons.speaker,
                      ),
                      title: Text("اشعار عند انتهاء كل ذكر"),
                    ),
                    activeColor: mainColor,
                    value: controller.isZikrDoneSoundAllowed,
                    onChanged: (value) {
                      controller.changeZikrDoneSoundStatus(value);

                      if (value) {
                        controller.playZikrDoneSound();
                      }
                      controller.update();
                    },
                  ),

                  /// Azkar Done Sound Allowed
                  SwitchListTile(
                    title: const ListTile(
                      contentPadding: EdgeInsets.all(0),
                      leading: Icon(
                        Icons.speaker,
                      ),
                      title: Text("اشعار عند انتهاء جميع الأذكار"),
                    ),
                    activeColor: mainColor,
                    value: controller.isAllAzkarFinishedSoundAllowed,
                    onChanged: (value) {
                      controller.changeAllAzkarFinishedSoundStatus(value);

                      if (value) {
                        controller.playAllAzkarFinishedSound();
                      }
                      controller.update();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}
