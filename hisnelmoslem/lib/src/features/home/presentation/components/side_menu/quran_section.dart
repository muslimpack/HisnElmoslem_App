import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/presentation/screens/fake_hadith.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/side_menu/shared.dart';
import 'package:hisnelmoslem/src/features/quran/presentation/controller/quran_controller.dart';
import 'package:hisnelmoslem/src/features/quran/presentation/screens/quran_read_page.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class QuranSection extends StatelessWidget {
  const QuranSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DrawerCard(
          child: ListTile(
            leading: Icon(MdiIcons.bookOpenPageVariant),
            title: Text(
              "end sura Ali 'Imran".tr,
            ),
            onTap: () {
              transitionAnimation.fromBottom2Top(
                context: context,
                goToPage: const QuranReadPage(
                  surahName: SurahNameEnum.endofAliImran,
                ),
              );
            },
          ),
        ),
        DrawerCard(
          child: ListTile(
            leading: Icon(MdiIcons.bookOpenPageVariant),
            title: Text(
              "sura Al-Kahf".tr,
            ),
            onTap: () {
              transitionAnimation.fromBottom2Top(
                context: context,
                goToPage: const QuranReadPage(
                  surahName: SurahNameEnum.alKahf,
                ),
              );
            },
          ),
        ),
        DrawerCard(
          child: ListTile(
            leading: Icon(MdiIcons.bookOpenPageVariant),
            title: Text("sura As-Sajdah".tr),
            onTap: () {
              transitionAnimation.fromBottom2Top(
                context: context,
                goToPage: const QuranReadPage(
                  surahName: SurahNameEnum.assajdah,
                ),
              );
            },
          ),
        ),
        DrawerCard(
          child: ListTile(
            leading: Icon(MdiIcons.bookOpenPageVariant),
            title: Text("sura Al-Mulk".tr),
            onTap: () {
              transitionAnimation.fromBottom2Top(
                context: context,
                goToPage: const QuranReadPage(
                  surahName: SurahNameEnum.alMulk,
                ),
              );
            },
          ),
        ),
        const DrawerDivider(),
        DrawerCard(
          child: ListTile(
            leading: const Icon(Icons.menu_book),
            title: Text("fake hadith".tr),
            onTap: () {
              transitionAnimation.fromBottom2Top(
                context: context,
                goToPage: const FakeHadith(),
              );
            },
          ),
        ),
      ],
    );
  }
}
