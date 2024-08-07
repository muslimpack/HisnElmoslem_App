import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/functions/open_url.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
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
            leading: Icon(MdiIcons.handClap),
            title: Text("Pray for us and our parents.".tr),
          ),
          ListTile(
            leading: Icon(MdiIcons.bookOpenPageVariant),
            title: Text("Quran pages is from android quran".tr),
            onTap: () {
              openURL("https://android.quran.com/");
            },
          ),
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
          ListTile(
            leading: Icon(MdiIcons.web),
            title: Text("Official Website".tr),
            subtitle: Text("Dr. Saeed bin Ali bin Wahf Al-Qahtani".tr),
            onTap: () {
              openURL("https://www.binwahaf.com/");
            },
          ),
          ListTile(
            leading: Icon(MdiIcons.github),
            title: Text("Github".tr),
            onTap: () async {
              await openURL(
                kOrgGithub,
              );
            },
          ),
        ],
      ),
    );
  }
}
