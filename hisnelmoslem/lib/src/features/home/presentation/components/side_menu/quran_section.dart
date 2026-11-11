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
    final colorScheme = Theme.of(context).colorScheme;
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    final tint = colorScheme.secondaryContainer.withValues(alpha: 0.35);
    final surahs = <(String, SurahNameEnum)>[
      (S.of(context).endSuraAliImran, SurahNameEnum.endofAliImran),
      (S.of(context).suraAlKahf, SurahNameEnum.alKahf),
      (S.of(context).suraAsSajdah, SurahNameEnum.assajdah),
      (S.of(context).suraAlMulk, SurahNameEnum.alMulk),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: shape,
          collapsedShape: shape,
          backgroundColor: tint,
          collapsedBackgroundColor: tint,
          leading: Icon(MdiIcons.bookOpenPageVariant, color: colorScheme.primary),
          title: Text(S.of(context).sourceQuran),
          childrenPadding: const EdgeInsets.only(bottom: 6),
          children: [
            for (final (title, surah) in surahs)
              DrawerTile(
                icon: MdiIcons.bookOpenPageVariant,
                title: title,
                onTap: () => context.push(QuranReadScreen(surahName: surah)),
              ),
          ],
        ),
      ),
    );
  }
}
