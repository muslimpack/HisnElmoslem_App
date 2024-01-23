import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/utils/open_url.dart';
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
          S.of(context).about_us,
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
            title:
                Text("${S.of(context).hisn_elmoslem_app_version} $appVersion"),
            subtitle: Text(
              S.of(context).free_ad_free_and_open_source_app,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(MdiIcons.handClap),
            title: Text(S.of(context).pray_for_us_and_our_parents),
          ),
          ListTile(
            leading: const Icon(MdiIcons.bookOpenPageVariant),
            title: Text(
              S.of(context).quran_pages_from_android_quran,
            ),
            onTap: () {
              openURL("https://android.quran.com/");
            },
          ),
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: Text(
              S
                  .of(context)
                  .digital_copy_of_hisn_elmoslem_used_from_aloka_network,
            ),
            subtitle: Text(
              S.of(context).dr_saeed_bin_ali_bin_wahf_al_qahtani,
            ),
            onTap: () {
              openURL("https://www.alukah.net/library/0/55211/");
            },
          ),
          ListTile(
            leading: const Icon(MdiIcons.web),
            title: Text(S.of(context).official_website),
            subtitle: Text(
              S.of(context).dr_saeed_bin_ali_bin_wahf_al_qahtani,
            ),
            onTap: () {
              openURL("https://www.binwahaf.com/");
            },
          ),
          ListTile(
            leading: const Icon(MdiIcons.github),
            title: Text(
              S.of(context).github,
            ),
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
