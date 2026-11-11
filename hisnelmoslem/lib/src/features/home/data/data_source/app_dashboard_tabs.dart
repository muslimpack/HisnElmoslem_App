import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/bookmark/presentation/screens/azkar_bookmarks_screen.dart';
import 'package:hisnelmoslem/src/features/bookmark/presentation/screens/titles_bookmarks_screen.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/screens/custom_titles_screen.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/pages/titles_screen.dart';
import 'package:hisnelmoslem/src/features/settings/data/models/app_component.dart';

final List<AppComponent> appDashboardTabs = [
  AppComponent(
    title: (context) => S.of(context).index,
    icon: Icons.menu_book_rounded,
    widget: const TitlesScreen(),
  ),
  AppComponent(
    title: (context) => S.of(context).favoritesContent,
    icon: Icons.bookmark_rounded,
    widget: const TitlesBookmarksScreen(),
  ),
  AppComponent(
    title: (context) => S.of(context).favoritesZikr,
    icon: Icons.favorite_rounded,
    widget: const AzkarBookmarksScreen(),
  ),
  AppComponent(
    title: (context) => S.of(context).customAzkar,
    icon: Icons.edit_note_rounded,
    widget: const CustomTitlesScreen(),
  ),
];
