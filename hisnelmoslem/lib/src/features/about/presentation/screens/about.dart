import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
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
          S.of(context).aboutUs,
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
            title: Text("${S.of(context).hisnElmoslemAppVersion} $appVersion"),
            subtitle: Text(S.of(context).freeAdFreeAndOpenSourceApp),
          ),
          const Divider(),
          ListTile(
            leading: Icon(MdiIcons.handClap),
            title: Text(S.of(context).prayForUsAndParents),
          ),
          ListTile(
            leading: Icon(MdiIcons.bookOpenPageVariant),
            title: Text(S.of(context).quranPagesFromAndroidQuran),
            onTap: () {
              openURL("https://android.quran.com/");
            },
          ),
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: Text(
              S.of(context).digitalCopyOfHisnElmoslem,
            ),
            subtitle: Text(S.of(context).drSaeedBinAliBinWahf),
            onTap: () {
              openURL("https://www.alukah.net/library/0/55211/");
            },
          ),
          ListTile(
            leading: Icon(MdiIcons.web),
            title: Text(S.of(context).officialWebsite),
            subtitle: Text(S.of(context).drSaeedBinAliBinWahf),
            onTap: () {
              openURL("https://www.binwahaf.com/");
            },
          ),
          ListTile(
            leading: Icon(MdiIcons.github),
            title: Text(S.of(context).github),
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
