import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/l10n.dart';

enum ZikrFilter {
  /// Source
  quran,
  sahihBukhari,
  sahihMuslim,
  abuDawood,
  atTirmidhi,
  anNasai,
  ibnMajah,
  malik,
  adDarami,
  ahmad,
  ibnSunny,
  hakim,
  bayhaqi,
  atTabarani,
  athar,

  /// Hokm
  hokmSahih,
  hokmHasan,
  hokmDaeif,
  hokmMawdue,
  hokmAthar,
}

extension ZikrFilterExt on ZikrFilter {
  List<ZikrFilter> get hokmFilters => [
        ZikrFilter.hokmSahih,
        ZikrFilter.hokmHasan,
        ZikrFilter.hokmDaeif,
        ZikrFilter.hokmMawdue,
        ZikrFilter.hokmAthar,
      ];

  bool get isForHokm => hokmFilters.contains(this);

  String get nameInDatabase {
    switch (this) {
      case ZikrFilter.quran:
        return "سورة";
      case ZikrFilter.sahihBukhari:
        return "بخار";
      case ZikrFilter.sahihMuslim:
        return "مسلم";
      case ZikrFilter.abuDawood:
        return "داود";
      case ZikrFilter.atTirmidhi:
        return "الترمذي";
      case ZikrFilter.anNasai:
        return "نسا";
      case ZikrFilter.ibnMajah:
        return "ماجه";
      case ZikrFilter.malik:
        return "مالك";
      case ZikrFilter.adDarami:
        return "دارم";
      case ZikrFilter.ahmad:
        return "أحمد";
      case ZikrFilter.ibnSunny:
        return "السني";
      case ZikrFilter.hakim:
        return "حاكم";
      case ZikrFilter.bayhaqi:
        return "بيهق";
      case ZikrFilter.atTabarani:
        return "طبران";
      case ZikrFilter.athar:
        return "أثر";

      ///
      case ZikrFilter.hokmSahih:
        return "صحيح";
      case ZikrFilter.hokmHasan:
        return "حسن";
      case ZikrFilter.hokmDaeif:
        return "ضعيف";
      case ZikrFilter.hokmMawdue:
        return "موضوع";
      case ZikrFilter.hokmAthar:
        return "أثر";
    }
  }

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
