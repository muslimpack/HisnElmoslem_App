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
        return "البخاري";
      case ZikrFilter.sahihMuslim:
        return "مسلم";
      case ZikrFilter.abuDawood:
        return "داود";
      case ZikrFilter.atTirmidhi:
        return "الترمذي";
      case ZikrFilter.anNasai:
        return "النسائي";
      case ZikrFilter.ibnMajah:
        return "ابن ماج";
      case ZikrFilter.malik:
        return "مالك";
      case ZikrFilter.adDarami:
        return "الدارمي";
      case ZikrFilter.ahmad:
        return "أحمد";
      case ZikrFilter.ibnSunny:
        return "ابن السني";
      case ZikrFilter.hakim:
        return "حاكم";
      case ZikrFilter.bayhaqi:
        return "بيهق";
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

  String get arabicName {
    switch (this) {
      case ZikrFilter.quran:
        return "القرآن";
      case ZikrFilter.sahihBukhari:
        return "صحيح البخاري";
      case ZikrFilter.sahihMuslim:
        return "صحيح مسلم";
      case ZikrFilter.abuDawood:
        return "سنن أبي داود";
      case ZikrFilter.atTirmidhi:
        return "سنن الترمذي";
      case ZikrFilter.anNasai:
        return "سنن النسائي";
      case ZikrFilter.ibnMajah:
        return "سنن ابن ماجه";
      case ZikrFilter.malik:
        return "موطأ مالك";
      case ZikrFilter.adDarami:
        return "مسند الدارمي";
      case ZikrFilter.ahmad:
        return "مسند أحمد";
      case ZikrFilter.ibnSunny:
        return "عمل اليوم والليلة لابن السني";
      case ZikrFilter.hakim:
        return "المستدرك على الصحيحين للحاكم النيسابوري";
      case ZikrFilter.bayhaqi:
        return "سنن البيهقي";
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

  String get englishName {
    switch (this) {
      case ZikrFilter.quran:
        return "Quran";
      case ZikrFilter.sahihBukhari:
        return "Sahih Bukhari";
      case ZikrFilter.sahihMuslim:
        return "Sahih Muslim";
      case ZikrFilter.abuDawood:
        return "Sunan Abu Dawood";
      case ZikrFilter.atTirmidhi:
        return "Sunan AtTirmidhi";
      case ZikrFilter.anNasai:
        return "Sunan AnNasai";
      case ZikrFilter.ibnMajah:
        return "Sunan IbnMajah";
      case ZikrFilter.malik:
        return "Malik";
      case ZikrFilter.adDarami:
        return "AdDarami";
      case ZikrFilter.ahmad:
        return "Ahmad";
      case ZikrFilter.ibnSunny:
        return "IbnSunny";
      case ZikrFilter.hakim:
        return "AlHakim";
      case ZikrFilter.bayhaqi:
        return "AlBayhaqi";
      case ZikrFilter.athar:
        return "Athr";

      ///
      case ZikrFilter.hokmSahih:
        return "Authentic";
      case ZikrFilter.hokmHasan:
        return "Good";
      case ZikrFilter.hokmDaeif:
        return "Weak";
      case ZikrFilter.hokmMawdue:
        return "Fabricated";
      case ZikrFilter.hokmAthar:
        return "Athar";
    }
  }
}
