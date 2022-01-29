import 'package:flutter/material.dart';
import 'package:hisnelmoslem/Shared/constant.dart';
import 'package:hisnelmoslem/shared/functions/open_url.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("عن التطبيق", style: TextStyle(fontFamily: "Uthmanic")),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
        ),
        body: ScrollConfiguration(
            behavior: ScrollBehavior(),
            child: GlowingOverscrollIndicator(
              axisDirection: AxisDirection.down,
              color: Colors.black26,
              child: ListView(
                children: [
                  SizedBox(height: 15),
                  ListTile(
                    leading: Image.asset(
                      'assets/images/app_icon.png',
                      scale: 3,
                    ),
                    title: Text("تطبيق حصن المسلم الإصدار " + APP_VERSION),
                    subtitle:
                        Text("تطبيق مجاني خالي من الإعلانات ومفتوح المصدر"),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(MdiIcons.bookOpenPageVariant),
                    title: Text("صفحات المصحف من خلال موقع tafsir.app"),
                    onTap: () {
                      openURL("https://tafsir.app/");
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.menu_book),
                    title: Text(
                        "تم الاستعانة بنسخة ديجتال من كتاب حصن المسلم من شبكة الألوكة"),
                    subtitle: Text(
                        "للفقير إلى الله تعالى الدكتور سعيد بن علي بن وهف القحطاني"),
                    onTap: () {
                      openURL("https://www.alukah.net/library/0/55211/");
                    },
                  ),
                ],
              ),
            )));
  }
}
