import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:hisnelmoslem/controllers/sounds_manager_controller.dart';

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
              title: Text("إدارة مؤثرات الصوت",
                  style: TextStyle(fontFamily: "Uthmanic")),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
            ),
            body: ScrollConfiguration(
              behavior: ScrollBehavior(),
              child: GlowingOverscrollIndicator(
                axisDirection: AxisDirection.down,
                color: black26,
                child: ListView(
                  physics: ClampingScrollPhysics(),
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
                    //   activeColor: MAINCOLOR,
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
                      title: ListTile(
                        contentPadding: EdgeInsets.all(0),
                        leading: Icon(
                          Icons.speaker,
                        ),
                        title: Text("صوت عند كل تسبيحة"),
                      ),
                      activeColor: MAINCOLOR,
                      value: controller.isTallySoundAllowed,
                      onChanged: (value) {
                        controller.changeTallySoundStatus(value);

                        if (value) {
                          controller.playTallySound();
                        } else {
                          // getSnackbar(
                          //     message: "تم الغاء منبه صيام الإثنين والخميس");
                        }
                        controller.update();
                      },
                    ),

                    /// Zikr Done Sound Allowed
                    SwitchListTile(
                      title: ListTile(
                        contentPadding: EdgeInsets.all(0),
                        leading: Icon(
                          Icons.speaker,
                        ),
                        title: Text("صوت عند انتهاء كل ذكر"),
                      ),
                      activeColor: MAINCOLOR,
                      value: controller.isZikrDoneSoundAllowed,
                      onChanged: (value) {
                        controller.changeZikrDoneSoundStatus(value);

                        if (value) {
                          controller.playZikrDoneSound();
                        } else {
                          // getSnackbar(
                          //     message: "تم الغاء منبه صيام الإثنين والخميس");
                        }
                        controller.update();
                      },
                    ),

                    /// Azkar Done Sound Allowed
                    SwitchListTile(
                      title: ListTile(
                        contentPadding: EdgeInsets.all(0),
                        leading: Icon(
                          Icons.speaker,
                        ),
                        title: Text("صوت عند انتهاء جميع الأذكار"),
                      ),
                      activeColor: MAINCOLOR,
                      value: controller.isAllAzkarFinishedSoundAllowed,
                      onChanged: (value) {
                        controller.changeAllAzkarFinishedSoundStatus(value);

                        if (value) {
                          controller.playAllAzkarFinishedSound();
                        } else {
                          // getSnackbar(
                          //     message: "تم الغاء منبه صيام الإثنين والخميس");
                        }
                        controller.update();
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
