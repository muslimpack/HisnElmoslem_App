import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/extensions/extension.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/side_menu/shared.dart';
import 'package:hisnelmoslem/src/features/quran/data/models/surah_name_enum.dart';
import 'package:hisnelmoslem/src/features/quran/presentation/screens/quran_read_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class QuranSection extends StatelessWidget {
  const QuranSection({super.key});

  @override
  Widget build(BuildContext context) {
    return DrawerCard(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(MdiIcons.bookOpenPageVariant),
          title: Text(S.of(context).sourceQuran), // You can change this key
          childrenPadding: const EdgeInsets.symmetric(horizontal: 8),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            ListTile(
              leading: Icon(MdiIcons.bookOpenPageVariant),
              title: Text(S.of(context).endSuraAliImran),
              onTap: () {
                context.push(const QuranReadScreen(surahName: SurahNameEnum.endofAliImran));
              },
            ),
            ListTile(
              leading: Icon(MdiIcons.bookOpenPageVariant),
              title: Text(S.of(context).suraAlKahf),
              onTap: () {
                context.push(const QuranReadScreen(surahName: SurahNameEnum.alKahf));
              },
            ),
            ListTile(
              leading: Icon(MdiIcons.bookOpenPageVariant),
              title: Text(S.of(context).suraAsSajdah),
              onTap: () {
                context.push(const QuranReadScreen(surahName: SurahNameEnum.assajdah));
              },
            ),
            ListTile(
              leading: Icon(MdiIcons.bookOpenPageVariant),
              title: Text(S.of(context).suraAlMulk),
              onTap: () {
                context.push(const QuranReadScreen(surahName: SurahNameEnum.alMulk));
              },
            ),
          ],
        ),
      ),
    );
  }
}
