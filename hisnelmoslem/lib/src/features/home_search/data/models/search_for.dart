import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';

enum SearchFor {
  title,
  content;

  static SearchFor fromString(String map) {
    return SearchFor.values.where((e) => e.name == map).firstOrNull ??
        SearchFor.title;
  }
}

extension SearchForExtension on SearchFor {
  String localeName(BuildContext context) {
    switch (this) {
      case SearchFor.title:
        return S.of(context).title;
      case SearchFor.content:
        return S.of(context).zikrContent;
    }
  }
}
