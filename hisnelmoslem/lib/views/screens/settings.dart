import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/shared/constants/constant.dart';
import 'package:hisnelmoslem/shared/functions/open_url.dart';
import 'package:hisnelmoslem/shared/functions/send_email.dart';
import 'package:hisnelmoslem/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/shared/widgets/scroll_glow_custom.dart';
import 'package:hisnelmoslem/views/screens/alarms_page.dart';
import 'package:hisnelmoslem/views/screens/sounds_manager_page.dart';
import 'package:hisnelmoslem/views/screens/themes_manager_page.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../controllers/app_data_controllers.dart';
import '../../controllers/settings_controller.dart';
import '../../shared/functions/get_snackbar.dart';
import '../../shared/widgets/font_settings.dart';
import 'about.dart';

class Settings extends StatelessWidget {
  Settings({Key? key}) : super(key: key);
  final AppDataController appDataController = Get.put(AppDataController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingsController>(
        init: SettingsController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              elevation: 0,
              title: const Text("الإعدادات",
                  style: TextStyle(fontFamily: "Uthmanic")),
              // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            ),
            body: ScrollGlowCustom(
              child: ListView(
                physics: const ClampingScrollPhysics(),
                children: [
                  const Title(title: 'عام'),
                  // SwitchListTile(
                  //   title: Row(
                  //     children: [
                  //       Icon(Icons.dark_mode),
                  //       Container(
                  //         margin: EdgeInsets.symmetric(horizontal: 30),
                  //         child: Text("الوضع المعتم"),
                  //       )
                  //     ],
                  //   ),
                  //   value: ThemeServices.isDarkMode(),
                  //   onChanged: (value) {
                  //     controller.toggleTheme();
                  //   },
                  // ),
                  !appDataController.isCardReadMode
                      ? ListTile(
                          leading: const Icon(MdiIcons.bookOpenPageVariant),
                          title: const Text("وضعية الصفحات"),
                          onTap: () {
                            appDataController.toggleReadModeStatus();
                            controller.update();
                          },
                        )
                      : ListTile(
                          leading: const Icon(MdiIcons.card),
                          title: const Text("وضعية البطاقات"),
                          onTap: () {
                            appDataController.toggleReadModeStatus();
                            controller.update();
                          },
                        ),
                  ListTile(
                    title: const Text("إدارة ألوان التطبيق"),
                    leading: const Icon(Icons.palette),
                    onTap: () {
                      transitionAnimation.fromBottom2Top(
                          context: context, goToPage: const ThemeManagerPage());
                    },
                  ),

                  ListTile(
                    title: const Text("إدارة مؤثرات الصوت"),
                    leading: const Icon(
                      Icons.speaker_group,
                    ),
                    onTap: () {
                      transitionAnimation.fromBottom2Top(
                          context: context,
                          goToPage: const SoundsManagerPage());
                    },
                  ),
                  const Divider(),
                  const Title(title: 'إعدادت الخط'),
                  const TextSample(),
                  FontSettingsToolbox(
                    controllerToUpdate: controller,
                  ),
                  const Divider(),
                  /**/
                  const Title(title: 'المنبهات'),
                  ListTile(
                    title: const Text("إدارة تنبيهات الأذكار"),
                    leading: const Icon(
                      Icons.alarm_add_rounded,
                    ),
                    onTap: () {
                      transitionAnimation.fromBottom2Top(
                          context: context, goToPage: const AlarmsPages());
                    },
                  ),
                  SwitchListTile(
                    title: const ListTile(
                      contentPadding: EdgeInsets.all(0),
                      leading: Icon(
                        Icons.person,
                      ),
                      title: Text("صيام الإثنين والخميس"),
                    ),
                    activeColor: mainColor,
                    value: appDataController.isFastAlarmEnabled,
                    onChanged: (value) {
                      appDataController.changFastAlarmStatus(value);

                      if (appDataController.isFastAlarmEnabled) {
                        getSnackbar(
                            message: "تم تفعيل منبه صيام الإثنين والخميس");
                      } else {
                        getSnackbar(
                            message: "تم الغاء منبه صيام الإثنين والخميس");
                      }
                      controller.update();
                    },
                  ),
                  SwitchListTile(
                    title: const ListTile(
                      contentPadding: EdgeInsets.all(0),
                      leading: Icon(
                        Icons.alarm,
                      ),
                      title: Text("تذكير قراءة سورة الكهف"),
                    ),
                    activeColor: mainColor,
                    value: appDataController.isCaveAlarmEnabled,
                    onChanged: (value) {
                      appDataController.changCaveAlarmStatus(value);

                      if (appDataController.isCaveAlarmEnabled) {
                        getSnackbar(message: "تم تفعيل تذكير سورة الكهف");
                      } else {
                        getSnackbar(message: "تم الغاء تذكير سورة الكهف");
                      }
                      controller.update();
                    },
                  ),
                  const Divider(),
                  /**/
                  const Title(title: 'التواصل'),
                  ListTile(
                    leading: const Icon(Icons.star),
                    title: const Text("الشكاوى والمقترحات"),
                    onTap: () {
                      sendEmail(
                          toMailId: 'hassaneltantawy@gmail.com',
                          subject: 'تطبيق حصن المسلم: تقييم التطبيق',
                          body: 'كم من عشرة تعطي هذا التطبيق؟'
                              '''
                              \n\n
                              'ملاحظات:'
                              \n\n
                              'ما أعجبك في التطبيق:'
                              \n\n
                              'ما لا يعجبك في التطبيق:'
                              \n\n
                              'شئ تتمنى وجوده:'
                              \n
                              ''');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text("راسلنا"),
                    onTap: () {
                      sendEmail(
                          toMailId: 'hassaneltantawy@gmail.com',
                          subject: 'تطبيق حصن المسلم: نداء',
                          body: 'السلام عليكم ورحمة الله وبركاته' '\n');
                    },
                  ),
                  ListTile(
                    leading: const Icon(MdiIcons.github),
                    trailing: const Icon(Icons.keyboard_arrow_left),
                    title: const Text("المشروع"),
                    onTap: () {
                      openURL(
                          'https://github.com/HasanEltantawy/HisnElmoslem_App');
                    },
                  ),
                  ListTile(
                      leading: const Icon(MdiIcons.information),
                      trailing: const Icon(Icons.keyboard_arrow_left),
                      title: const Text("عن التطبيق"),
                      onTap: () {
                        transitionAnimation.fromBottom2Top(
                            context: context, goToPage: const About());
                      }),
                  const Divider(),
                ],
              ),
            ),
          );
        });
  }
}

class Title extends StatelessWidget {
  final String title;

  const Title({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // leading: Icon(Icons.bookmark_border),

      title: Text(
        title,
        style: TextStyle(fontSize: 20, color: mainColor),
      ),
    );
  }
}
