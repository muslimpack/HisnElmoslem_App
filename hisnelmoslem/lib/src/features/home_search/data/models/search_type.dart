import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';

enum SearchType {
  typical,
  allWords,
  anyWords;

  static SearchType fromString(String map) {
    return SearchType.values.where((e) => e.name == map).firstOrNull ??
        SearchType.typical;
  }
}

extension SearchTypeExtension on SearchType {
  String localeName(BuildContext context) {
    switch (this) {
      case SearchType.typical:
        return S.of(context).typical;
      case SearchType.allWords:
        return S.of(context).allWords;
      case SearchType.anyWords:
        return S.of(context).anyWords;
    }
  }
}
