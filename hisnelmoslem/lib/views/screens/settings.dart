import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/shared/constants/constant.dart';
import 'package:hisnelmoslem/shared/functions/open_url.dart';
import 'package:hisnelmoslem/shared/functions/send_email.dart';
import 'package:hisnelmoslem/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/themes/theme_services.dart';
import 'package:hisnelmoslem/views/screens/alarms_page.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../controllers/app_data_controllers.dart';
import '../../controllers/settings_controller.dart';
import '../../shared/functions/get_snackbar.dart';
import '../../shared/widgets/font_settings.dart';
import 'about.dart';

class Settings extends StatelessWidget {
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
              title:
                  Text("الإعدادات", style: TextStyle(fontFamily: "Uthmanic")),
              // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            ),
            body: ScrollConfiguration(
              behavior: ScrollBehavior(),
              child: GlowingOverscrollIndicator(
                axisDirection: AxisDirection.down,
                color: black26,
                child: ListView(
                  physics: ClampingScrollPhysics(),
                  children: [
                    Title(title: 'عام'),
                    SwitchListTile(
                      title: Row(
                        children: [
                          Icon(Icons.dark_mode),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 30),
                            child: Text("الوضع المعتم"),
                          )
                        ],
                      ),
                      value: ThemeServices.isDarkMode(),
                      onChanged: (value) {
                        controller.toggleTheme();
                      },
                    ),
                    !appDataController.isCardReadMode
                        ? ListTile(
                            leading: Icon(MdiIcons.bookOpenPageVariant),
                            title: Text("وضعية الصفحات"),
                            onTap: () {
                              appDataController.toggleReadModeStatus();
                              controller.update();
                            },
                          )
                        : ListTile(
                            leading: Icon(MdiIcons.card),
                            title: Text("وضعية البطاقات"),
                            onTap: () {
                              appDataController.toggleReadModeStatus();
                              controller.update();
                            },
                          ),
                    Divider(),
                    Title(title: 'إعدادت الخط'),
                    TextSample(),
                    FontSettingsToolbox(
                      controllerToUpdate: controller,
                    ),
                    Divider(),
                    /**/
                    Title(title: 'المنبهات'),
                    ListTile(
                      title: Text("إدارة تنبيهات الأذكار"),
                      leading: Icon(
                        Icons.alarm_add_rounded,
                      ),
                      onTap: () {
                        transitionAnimation.fromBottom2Top(
                            context: context, goToPage: AlarmsPages());
                      },
                    ),
                    SwitchListTile(
                      title: ListTile(
                        contentPadding: EdgeInsets.all(0),
                        leading: Icon(
                          Icons.person,
                        ),
                        title: Text("صيام الإثنين والخميس"),
                      ),
                      activeColor: MAINCOLOR,
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
                      title: ListTile(
                        contentPadding: EdgeInsets.all(0),
                        leading: Icon(
                          Icons.alarm,
                        ),
                        title: Text("تذكير قراءة سورة الكهف"),
                      ),
                      activeColor: MAINCOLOR,
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
                    Divider(),
                    /**/
                    Title(title: 'التواصل'),
                    ListTile(
                      leading: Icon(Icons.star),
                      title: Text("الشكاوى والمقترحات"),
                      onTap: () {
                        sendEmail(
                            toMailId: 'hassaneltantawy@gmail.com',
                            subject: 'تطبيق حصن المسلم: تقييم التطبيق',
                            body: 'كم من عشرة تعطي هذا التطبيق؟' +
                                '\n' +
                                '\n' +
                                'ملاحظات:' +
                                '\n' +
                                '\n' +
                                'ما أعجبك في التطبيق:' +
                                '\n' +
                                '\n' +
                                'ما لا يعجبك في التطبيق:' +
                                '\n' +
                                '\n' +
                                'شئ تتمنى وجوده:' +
                                '\n');
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.email),
                      title: Text("راسلنا"),
                      onTap: () {
                        sendEmail(
                            toMailId: 'hassaneltantawy@gmail.com',
                            subject: 'تطبيق حصن المسلم: نداء',
                            body: 'السلام عليكم ورحمة الله وبركاته' + '\n');
                      },
                    ),
                    ListTile(
                      leading: Icon(MdiIcons.github),
                      trailing: Icon(Icons.keyboard_arrow_left),
                      title: Text("المشروع"),
                      onTap: () {
                        openURL(
                            'https://github.com/HasanEltantawy/HisnElmoslem_App');
                      },
                    ),
                    ListTile(
                        leading: Icon(MdiIcons.information),
                        trailing: Icon(Icons.keyboard_arrow_left),
                        title: Text("عن التطبيق"),
                        onTap: () {
                          transitionAnimation.fromBottom2Top(
                              context: context, goToPage: About());
                        }),
                    Divider(),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class Title extends StatelessWidget {
  final String title;

  Title({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListTile(
        // leading: Icon(Icons.bookmark_border),

        title: Text(
          title,
          style: TextStyle(fontSize: 20, color: MAINCOLOR),
        ),
      ),
    );
  }
}
