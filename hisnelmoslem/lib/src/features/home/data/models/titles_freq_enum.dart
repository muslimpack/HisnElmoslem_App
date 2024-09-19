import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/l10n.dart';

enum TitlesFreqEnum {
  daily,
  week,
  month,
  year,
}

extension TitlesFreqEnumExt on TitlesFreqEnum {
  String localeName(BuildContext context) {
    switch (this) {
      case TitlesFreqEnum.daily:
        return S.of(context).freqDaily;
      case TitlesFreqEnum.week:
        return S.of(context).freqWeekly;

      case TitlesFreqEnum.month:
        return S.of(context).freqMonthly;

      case TitlesFreqEnum.year:
        return S.of(context).freqAnnual;
    }
  }

  String toJson() {
    return name;
  }

  static TitlesFreqEnum fromJson(String jsonString) {
    return TitlesFreqEnum.values.firstWhere((e) => e.name == jsonString);
  }
}

extension TitlesFreqEnumListExt on List<TitlesFreqEnum> {
  bool validate(String freq) {
    bool isValid = false;

    for (var i = 0; i < length; i++) {
      final freqTxt = this[i].name[0].toLowerCase();

      isValid = freq.toLowerCase().contains(freqTxt);

      if (isValid) break;
    }

    return isValid;
  }

  String toJson() {
    final List<String> jsonList = map((e) => e.toJson()).toList();
    return jsonList.join(',');
  }

  List<TitlesFreqEnum> toEnumList(String jsonString) {
    final List<String> jsonList = jsonString.split(',');
    return jsonList.map((e) => TitlesFreqEnumExt.fromJson(e)).toList();
  }
}
