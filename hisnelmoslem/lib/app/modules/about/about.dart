import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/app/shared/functions/open_url.dart';
import 'package:hisnelmoslem/core/values/constant.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class About extends StatelessWidget {
  const About({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "about us".tr,
          style: const TextStyle(fontFamily: "Uthmanic"),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(height: 15),
          ListTile(
            leading: Image.asset(
              'assets/images/app_icon.png',
              scale: 3,
            ),
            title: Text("${"Hisn ELmoslem App Version".tr} $appVersion"),
            subtitle: Text("Free, ad-free and open source app".tr),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(MdiIcons.handClap),
            title: Text("Pray for us and our parents.".tr),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(MdiIcons.bookOpenPageVariant),
            title: Text("Quran pages is from android quran".tr),
            onTap: () {
              openURL("https://android.quran.com/");
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: Text(
              "A digital copy of Hisn Elmoslem was used from the Aloka Network."
                  .tr,
            ),
            subtitle: Text("Dr. Saeed bin Ali bin Wahf Al-Qahtani".tr),
            onTap: () {
              openURL("https://www.alukah.net/library/0/55211/");
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(MdiIcons.web),
            title: Text("Official Website".tr),
            subtitle: Text("Dr. Saeed bin Ali bin Wahf Al-Qahtani".tr),
            onTap: () {
              openURL("https://www.binwahaf.com/");
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(MdiIcons.github),
            title: Text("Github".tr),
            onTap: () async {
              await openURL(
                'https://github.com/muslimpack/HisnElmoslem_App',
              );
            },
          ),
        ],
      ),
    );
  }
}
