enum TitlesFreqEnum {
  daily,
  week,
  month,
  year,
}

extension TitlesFreqEnumExt on TitlesFreqEnum {
  String get arabicName {
    switch (this) {
      case TitlesFreqEnum.daily:
        return "يومي";
      case TitlesFreqEnum.week:
        return "أسبوعي";
      case TitlesFreqEnum.month:
        return "شهري";
      case TitlesFreqEnum.year:
        return "سنوي";
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
