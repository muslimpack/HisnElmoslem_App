import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/extensions/extension.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/presentation/screens/fake_hadith_dashboard_screen.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/side_menu/header_section.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/side_menu/more_section.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/side_menu/quran_section.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/side_menu/shared.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/screens/tally_dashboard_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Column(
      children: [
        const HeaderSection(),
        Expanded(
          child: SafeArea(
            top: false,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 12),
              children: [
                DrawerReveal(order: 0, child: DrawerSectionLabel(s.drawerSectionRead)),
                const DrawerReveal(order: 1, child: QuranSection()),
                DrawerReveal(
                  order: 2,
                  child: DrawerTile(
                    icon: Icons.menu_book_rounded,
                    title: s.fakeHadith,
                    onTap: () => context.push(const FakeHadithDashboardScreen()),
                  ),
                ),
                DrawerReveal(order: 3, child: DrawerSectionLabel(s.drawerSectionTools)),
                DrawerReveal(
                  order: 4,
                  child: DrawerTile(
                    icon: MdiIcons.counter,
                    title: s.tally,
                    onTap: () => context.push(const TallyDashboardScreen()),
                  ),
                ),
                DrawerReveal(order: 5, child: DrawerSectionLabel(s.drawerSectionMore)),
                const MoreSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
