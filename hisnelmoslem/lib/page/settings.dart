import 'package:hisnelmoslem/Screen/about.dart';
import 'package:hisnelmoslem/provider/azkar_mode.dart';
import 'package:hisnelmoslem/provider/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  Settings({Key key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool isDark = false;
  bool val = true;
  bool status = false;
  bool isExpand;
  onSwitchValueChanged(bool newVal) {
    setState(() {
      val = newVal;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context);
    final azkarMode = Provider.of<AzkarMode>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        centerTitle: true,
        title: new Text(
          "الإعدادات",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25),
        ),
      ),
      body: ListView(
        children: <Widget>[
          const SizedBox(height: 10),
          Card(
            elevation: 20,
            margin: EdgeInsets.fromLTRB(10, 15, 10, 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: <Widget>[
                new ListTile(
                  title: Text(
                    "عام",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                BuildDiv(),
                Container(
                  child: new Row(
                    children: <Widget>[
                      new Expanded(
                        flex: 2,
                        child: Column(
                          children: <Widget>[
                            new Directionality(
                                textDirection: TextDirection.rtl,
                                child: new ListTile(
                                  leading: theme.getTheme() == ThemeData.dark()
                                      ? Icon(Icons.wb_sunny)
                                      : Icon(MdiIcons.weatherNight),
                                  title: Text(
                                    theme.getTheme() == ThemeData.dark()
                                        ? "الوضع الفاتح"
                                        : "الوضع المعتم",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onTap: () {
                                    theme.getTheme() == ThemeData.dark()
                                        ? theme.setTheme(ThemeData.light())
                                        : theme.setTheme(ThemeData.dark());
                                  },
                                )),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                BuildDiv(), //
                Container(
                  child: new Row(
                    children: <Widget>[
                      new Expanded(
                        flex: 2,
                        child: Column(
                          children: <Widget>[
                            new Directionality(
                                textDirection: TextDirection.rtl,
                                child: new ListTile(
                                  leading: azkarMode.getAzkarMode() == "Card"
                                      ? Icon(MdiIcons.card)
                                      : Icon(MdiIcons.bookOpenPageVariant),
                                  title: Text(
                                    azkarMode.getAzkarMode() == "Card"
                                        ? "وضع البطاقات"
                                        : "وضع الصفحات",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onTap: () {
                                    azkarMode.toggleAzkarMode();
                                  },
                                )),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Card(
            elevation: 20,
            margin: EdgeInsets.fromLTRB(10, 5, 10, 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: <Widget>[
                new ListTile(
                  title: Text(
                    "التواصل",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                BuildDiv(),
                new Directionality(
                    textDirection: TextDirection.rtl,
                    child: new ListTile(
                      leading: Icon(MdiIcons.star),
                      title: Text(
                        "تقييم التطبيق",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        _launchURL(
                            'hassaneltantawy@gmail.com',
                            'تطبيق حصن المسلم: تقييم التطبيق',
                            'كم من عشرة تعطي هذا التطبيق؟' +
                                '<br>' +
                                '<br>' +
                                'ملاحظات:' +
                                '<br>' +
                                '<br>' +
                                'ما أعجبك في التطبيق:' +
                                '<br>' +
                                '<br>' +
                                'ما لا يعجبك في التطبيق:' +
                                '<br>' +
                                '<br>' +
                                'شئ تتمنى وجوده:' +
                                '<br>');
                      },
                    )),
                BuildDiv(),
                new Directionality(
                    textDirection: TextDirection.rtl,
                    child: new ListTile(
                      leading: Icon(MdiIcons.email),
                      title: Text(
                        "راسلنا",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        _launchURL(
                            'hassaneltantawy@gmail.com',
                            'تطبيق حصن المسلم: نداء',
                            'السلام عليكم ورحمة الله وبركاته' + '<br>');
                      },
                    )),
                BuildDiv(),
                new Directionality(
                    textDirection: TextDirection.rtl,
                    child: new ListTile(
                      leading: Icon(MdiIcons.github),
                      trailing: Icon(Icons.keyboard_arrow_left),
                      title: Text(
                        "المشروع",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        _launchUrl(
                            'https://github.com/HasanEltantawy/HisnElmoslem_App');
                      },
                    )),
                BuildDiv(),
                new Directionality(
                    textDirection: TextDirection.rtl,
                    child: new ListTile(
                      leading: Icon(MdiIcons.information),
                      trailing: Icon(Icons.keyboard_arrow_left),
                      title: Text(
                        "عن التطبيق",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => About()),
                        );
                      },
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _launchURL(String toMailId, String subject, String body) async {
    var url = 'mailto:$toMailId?subject=$subject&body=$body';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

_launchUrl(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

class BuildDiv extends StatelessWidget {
  const BuildDiv({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      width: double.infinity,
      height: 1.0,
      color: Theme.of(context).backgroundColor,
    );
  }
}
