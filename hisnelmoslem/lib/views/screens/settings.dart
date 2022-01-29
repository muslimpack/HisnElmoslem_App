import 'package:flutter/material.dart';
import 'package:hisnelmoslem/Shared/constant.dart';
import 'package:hisnelmoslem/providers/app_settings.dart';
import 'package:hisnelmoslem/shared/functions/open_url.dart';
import 'package:hisnelmoslem/shared/functions/send_email.dart';
import 'package:hisnelmoslem/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/utils/notification_manager.dart';
import 'package:hisnelmoslem/views/screens/alarms_page.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'about.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    final appSettings = Provider.of<AppSettingsNotifier>(context);
    String azkarReadMode = appSettings.getAzkarReadMode();
    late bool isPage;
    if (azkarReadMode == "Page") {
      isPage = true;
    } else if (azkarReadMode == "Card") {
      isPage = false;
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("الإعدادات", style: TextStyle(fontFamily: "Uthmanic")),
        // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: ScrollConfiguration(
        behavior: ScrollBehavior(),
        child: GlowingOverscrollIndicator(
          axisDirection: AxisDirection.down,
          color: Colors.black26,
          child: ListView(
            physics: ClampingScrollPhysics(),
            children: [
              Title(title: 'عام'),
              isPage
                  ? ListTile(
                      // leading: Icon(Icons.bookmark_border),
                      leading: Icon(MdiIcons.bookOpenPageVariant),
                      title: Text("وضعية الصفحات"),

                      onTap: () {
                        setState(() {
                          appSettings.toggleAzkarReadMode();
                        });
                      },
                    )
                  : ListTile(
                      // leading: Icon(Icons.bookmark_border),
                      leading: Icon(MdiIcons.card),
                      title: Text("وضعية البطاقات"),

                      onTap: () {
                        setState(() {
                          appSettings.toggleAzkarReadMode();
                        });
                      },
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
              // SwitchListTile(
              //     title: ListTile(
              //       contentPadding: EdgeInsets.all(0),
              //       leading: Icon(
              //         Icons.wb_sunny_sharp,
              //       ),
              //       title: Text("أذكار الصباح"),
              //     ),
              //     activeColor: MAINCOLOR,
              //     value: appSettings.getRMorning(),
              //     onChanged: (value) {
              //       setState(() {
              //         appSettings.setRMorning(value);
              //       });
              //       if (appSettings.getRMorning()) {
              //         localNotifyManager.customShowNotification(
              //             showTime: 1000,
              //             id: 10,
              //             title: "تم تفعيل منبة أذكار الصباح");
              //       } else if (!appSettings.getRMorning()) {
              //         localNotifyManager.customShowNotification(
              //             showTime: 1000,
              //             id: 10,
              //             title: "تم الغاء منبة أذكار الصباح");
              //       }
              //     }),
              // SwitchListTile(
              //     title: ListTile(
              //       contentPadding: EdgeInsets.all(0),
              //       // leading: Icon(Icons.bookmark_border),
              //       leading: Icon(
              //         Icons.nightlight_round,
              //       ),
              //       title: Text("أذكار المساء"),
              //     ),
              //     activeColor: MAINCOLOR,
              //     value: appSettings.getRNight(),
              //     onChanged: (value) {
              //       setState(() {
              //         appSettings.setRNight(value);
              //       });
              //
              //       if (appSettings.getRNight()) {
              //         localNotifyManager.customShowNotification(
              //             showTime: 1000,
              //             id: 20,
              //             title: "تم تفعيل منبة أذكار المساء");
              //       } else if (!appSettings.getRNight()) {
              //         localNotifyManager.customShowNotification(
              //             showTime: 1000,
              //             id: 20,
              //             title: "تم الغاء منبة أذكار المساء");
              //       }
              //     }),
              // SwitchListTile(
              //   title: ListTile(
              //     contentPadding: EdgeInsets.all(0),
              //     // leading: Icon(Icons.bookmark_border),
              //     leading: Icon(
              //       Icons.alarm,
              //     ),
              //     title: Text("أذكار الإستيقاظ"),
              //   ),
              //   activeColor: MAINCOLOR,
              //   value: appSettings.getRWakeup(),
              //   onChanged: (value) {
              //     setState(() {
              //       appSettings.setRWakeup(value);
              //     });
              //     if (appSettings.getRWakeup()) {
              //       localNotifyManager.customShowNotification(
              //           showTime: 1000,
              //           id: 30,
              //           title: "تم تفعيل منبة أذكار الاستيقاظ");
              //     } else if (!appSettings.getRWakeup()) {
              //       localNotifyManager.customShowNotification(
              //           showTime: 1000,
              //           id: 30,
              //           title: "تم الغاء منبة أذكار الاستيقاظ");
              //     }
              //   },
              // ),
              // SwitchListTile(
              //   title: ListTile(
              //     contentPadding: EdgeInsets.all(0),
              //     // leading: Icon(Icons.bookmark_border),
              //     leading: Icon(
              //       MdiIcons.sleep,
              //     ),
              //     title: Text("أذكار النوم"),
              //   ),
              //   activeColor: MAINCOLOR,
              //   value: appSettings.getRSleep(),
              //   onChanged: (value) {
              //     setState(() {
              //       appSettings.setRSleep(value);
              //     });
              //     if (appSettings.getRSleep()) {
              //       localNotifyManager.customShowNotification(
              //           showTime: 1000,
              //           id: 40,
              //           title: "تم تفعيل منبة أذكار النوم");
              //     } else if (!appSettings.getRSleep()) {
              //       localNotifyManager.customShowNotification(
              //           showTime: 1000,
              //           id: 40,
              //           title: "تم الغاء منبة أذكار النوم");
              //     }
              //   },
              // ),
              SwitchListTile(
                title: ListTile(
                  contentPadding: EdgeInsets.all(0),
                  // leading: Icon(Icons.bookmark_border),
                  leading: Icon(
                    Icons.person,
                  ),
                  title: Text("صيام الإثنين والخميس"),
                ),
                activeColor: MAINCOLOR,
                value: appSettings.getRFastTwice(),
                onChanged: (value) {
                  setState(() {
                    appSettings.setRFastTwice(value);
                  });
                  if (appSettings.getRFastTwice()) {
                    localNotifyManager.showCustomNotification(
                        title: "تم تفعيل منبه صيام الإثنين والخميس",
                        payload: '');
                  } else if (!appSettings.getRFastTwice()) {
                    localNotifyManager.showCustomNotification(
                        title: "تم الغاء منبه صيام الإثنين والخميس",
                        payload: '');
                  }
                },
              ),
              SwitchListTile(
                title: ListTile(
                  contentPadding: EdgeInsets.all(0),
                  // leading: Icon(Icons.bookmark_border),
                  leading: Icon(
                    Icons.alarm,
                  ),
                  title: Text("تذكير قراءة سورة الكهف"),
                ),
                activeColor: MAINCOLOR,
                value: appSettings.getRCave(),
                onChanged: (value) {
                  setState(() {
                    appSettings.setRCave(value);
                  });
                  if (appSettings.getRCave()) {
                    localNotifyManager.showCustomNotification(
                        title: "تم تفعيل تذكير سورة الكهف", payload: '');
                  } else if (!appSettings.getRCave()) {
                    localNotifyManager.showCustomNotification(
                        title: "تم الغاء تذكير سورة الكهف", payload: '');
                  }
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
                  openURL('https://github.com/HasanEltantawy/HisnElmoslem_App');
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
