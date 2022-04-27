import 'package:flutter/material.dart';
import 'package:hisnelmoslem/shared/constants/constant.dart';
import 'package:hisnelmoslem/shared/functions/open_url.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class About extends StatelessWidget {
  const About({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("عن التطبيق",
              style: TextStyle(fontFamily: "Uthmanic")),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
        ),
        body: ScrollConfiguration(
            behavior: const ScrollBehavior(),
            child: GlowingOverscrollIndicator(
              axisDirection: AxisDirection.down,
              color: black26,
              child: ListView(
                children: [
                  const SizedBox(height: 15),
                  ListTile(
                    leading: Image.asset(
                      'assets/images/app_icon.png',
                      scale: 3,
                    ),
                    title: const Text("تطبيق حصن المسلم الإصدار " + appVersion),
                    subtitle: const Text(
                        "تطبيق مجاني خالي من الإعلانات ومفتوح المصدر"),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(MdiIcons.bookOpenPageVariant),
                    title: const Text("صفحات المصحف من خلال موقع tafsir.app"),
                    onTap: () {
                      openURL("https://tafsir.app/");
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.menu_book),
                    title: const Text(
                        "تم الاستعانة بنسخة ديجتال من كتاب حصن المسلم من شبكة الألوكة"),
                    subtitle: const Text(
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
