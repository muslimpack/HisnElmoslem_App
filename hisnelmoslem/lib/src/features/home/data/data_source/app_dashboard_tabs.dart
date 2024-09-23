import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/pages/azkar_bookmarks_screen.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/pages/titles_bookmarks_screen.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/pages/titles_screen.dart';
import 'package:hisnelmoslem/src/features/settings/data/models/app_component.dart';

final List<AppComponent> appDashboardTabs = [
  AppComponent(
    title: (context) => S.of(context).index,
    widget: const TitlesScreen(),
  ),
  AppComponent(
    title: (context) => S.of(context).favoritesContent,
    widget: const TitlesBookmarksScreen(),
  ),
  AppComponent(
    title: (context) => S.of(context).favoritesZikr,
    widget: const AzkarBookmarksScreen(),
  ),
];
