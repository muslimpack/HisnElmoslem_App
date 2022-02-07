import 'package:flutter/material.dart';
import 'package:hisnelmoslem/providers/app_settings.dart';
import 'package:hisnelmoslem/shared/constants/constant.dart';
import 'package:hisnelmoslem/shared/functions/open_url.dart';
import 'package:hisnelmoslem/shared/functions/send_email.dart';
import 'package:hisnelmoslem/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/views/screens/alarms_page.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import '../../shared/functions/get_snackbar.dart';
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
          color: black26,
          child: ListView(
            physics: ClampingScrollPhysics(),
            children: [
              Title(title: 'عام'),
              isPage
                  ? ListTile(
                      leading: Icon(MdiIcons.bookOpenPageVariant),
                      title: Text("وضعية الصفحات"),
                      onTap: () {
                        setState(() {
                          appSettings.toggleAzkarReadMode();
                        });
                      },
                    )
                  : ListTile(
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
              SwitchListTile(
                title: ListTile(
                  contentPadding: EdgeInsets.all(0),
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
                    getSnackbar(message: "تم تفعيل منبه صيام الإثنين والخميس");
                  } else if (!appSettings.getRFastTwice()) {
                    getSnackbar(message: "تم الغاء منبه صيام الإثنين والخميس");
                  }
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
                value: appSettings.getRCave(),
                onChanged: (value) {
                  setState(() {
                    appSettings.setRCave(value);
                  });
                  if (appSettings.getRCave()) {
                    getSnackbar(message: "تم تفعيل تذكير سورة الكهف");
                  } else if (!appSettings.getRCave()) {
                    getSnackbar(message: "تم الغاء تذكير سورة الكهف");
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
