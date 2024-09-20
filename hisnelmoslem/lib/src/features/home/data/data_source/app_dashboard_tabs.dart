import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/pages/bookmarks.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/pages/favorite_zikr.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/pages/fehrs.dart';
import 'package:hisnelmoslem/src/features/settings/data/models/app_component.dart';

final List<AppComponent> appDashboardTabs = [
  AppComponent(
    title: (context) => S.of(context).index,
    widget: const AzkarFehrs(),
  ),
  AppComponent(
    title: (context) => S.of(context).favoritesContent,
    widget: const AzkarBookmarks(),
  ),
  AppComponent(
    title: (context) => S.of(context).favoritesZikr,
    widget: const FavouriteZikr(),
  ),
];
