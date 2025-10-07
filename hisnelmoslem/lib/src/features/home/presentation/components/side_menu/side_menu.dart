import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/extensions/extension.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/presentation/screens/fake_hadith_dashboard_screen.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/side_menu/footer_section.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/side_menu/header_section.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/side_menu/more_section.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/side_menu/quran_section.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/side_menu/shared.dart';
import 'package:hisnelmoslem/src/features/settings/presentation/screens/settings_screen.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/screens/tally_dashboard_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const HeaderSection(),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    children: [
                      DrawerCard(
                        child: ListTile(
                          leading: Icon(MdiIcons.counter),
                          title: Text(S.of(context).tally),
                          onTap: () {
                            context.push(const TallyDashboardScreen());
                          },
                        ),
                      ),
                      const DrawerDivider(),
                      const QuranSection(),
                      const DrawerDivider(),
                      ListTile(
                        leading: const Icon(Icons.menu_book),
                        title: Text(S.of(context).fakeHadith),
                        onTap: () {
                          context.push(const FakeHadithDashboardScreen());
                        },
                      ),
                      const DrawerDivider(),
                      DrawerCard(
                        child: ListTile(
                          leading: const Icon(Icons.settings),
                          title: Text(S.of(context).settings),
                          onTap: () {
                            context.push(const SettingsScreen());
                          },
                        ),
                      ),
                      const DrawerDivider(),
                      const MoreSection(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const FooterSection(),
        ],
      ),
    );
  }
}
