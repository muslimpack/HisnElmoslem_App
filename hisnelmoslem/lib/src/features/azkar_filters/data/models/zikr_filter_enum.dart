import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';

enum ZikrFilter {
  /// Source
  quran("سورة", false),
  sahihBukhari("بخار", false),
  sahihMuslim("مسلم", false),
  abuDawood("داود", false),
  atTirmidhi("الترمذي", false),
  anNasai("نسا", false),
  ibnMajah("ماجه", false),
  malik("موط", false),
  adDarami("دارم", false),
  ahmad("أحمد", false),
  ibnSunny("السني", false),
  hakim("حاكم", false),
  bayhaqi("بيهق", false),
  atTabarani("طبران", false),
  athar("أثر", false),

  /// Hokm
  hokmQuran("قرآن", true),
  hokmSahih("صحيح", true),
  hokmHasan("حسن", true),
  hokmDaeif("ضعيف", true),
  hokmMawdue("موضوع", true),
  hokmAthar("أثر", true);

  const ZikrFilter(this.lookupWord, this.isForHokm);
  final String lookupWord;
  final bool isForHokm;
}

extension ZikrFilterExt on ZikrFilter {
  String localeName(BuildContext context) {
    switch (this) {
      case ZikrFilter.quran:
        return S.of(context).sourceQuran;
      case ZikrFilter.sahihBukhari:
        return S.of(context).sourceSahihBukhari;
      case ZikrFilter.sahihMuslim:
        return S.of(context).sourceSahihMuslim;
      case ZikrFilter.abuDawood:
        return S.of(context).sourceAbuDawood;
      case ZikrFilter.atTirmidhi:
        return S.of(context).sourceAtTirmidhi;
      case ZikrFilter.anNasai:
        return S.of(context).sourceAnNasai;
      case ZikrFilter.ibnMajah:
        return S.of(context).sourceIbnMajah;
      case ZikrFilter.malik:
        return S.of(context).sourceMalik;
      case ZikrFilter.adDarami:
        return S.of(context).sourceAdDarami;
      case ZikrFilter.ahmad:
        return S.of(context).sourceAhmad;
      case ZikrFilter.ibnSunny:
        return S.of(context).sourceIbnSunny;
      case ZikrFilter.hakim:
        return S.of(context).sourceHakim;
      case ZikrFilter.bayhaqi:
        return S.of(context).sourceBayhaqi;
      case ZikrFilter.athar:
        return S.of(context).sourceAthar;
      case ZikrFilter.atTabarani:
        return S.of(context).sourceAtTabarani;

      ///
      case ZikrFilter.hokmQuran:
        return S.of(context).sourceQuran;
      case ZikrFilter.hokmSahih:
        return S.of(context).hokmSahih;
      case ZikrFilter.hokmHasan:
        return S.of(context).hokmHasan;
      case ZikrFilter.hokmDaeif:
        return S.of(context).hokmDaeif;
      case ZikrFilter.hokmMawdue:
        return S.of(context).hokmMawdue;
      case ZikrFilter.hokmAthar:
        return S.of(context).hokmAthar;
    }
  }
}
