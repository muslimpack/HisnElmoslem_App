import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/side_menu/footer_section.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/side_menu/header_section.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/side_menu/more_section.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/side_menu/quran_section.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/side_menu/shared.dart';
import 'package:hisnelmoslem/src/features/settings/presentation/screens/settings.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/screens/tally_dashboard.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    super.key,
  });

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
                          leading: Icon(
                            MdiIcons.counter,
                          ),
                          title: Text("tally".tr),
                          onTap: () {
                            transitionAnimation.fromBottom2Top(
                              context: context,
                              goToPage: const Tally(),
                            );
                          },
                        ),
                      ),
                      const DrawerDivider(),
                      const QuranSection(),
                      const DrawerDivider(),
                      DrawerCard(
                        child: ListTile(
                          leading: const Icon(Icons.settings),
                          title: Text("settings".tr),
                          onTap: () {
                            transitionAnimation.fromBottom2Top(
                              context: context,
                              goToPage: const Settings(),
                            );
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
