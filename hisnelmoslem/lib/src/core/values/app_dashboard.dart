import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/pages/bookmarks.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/pages/favorite_zikr.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/pages/fehrs.dart';
import 'package:hisnelmoslem/src/features/settings/data/models/app_component.dart';

final List<AppComponent> appDashboardItem = [
  AppComponent(
    title: S.current.index,
    widget: const AzkarFehrs(),
  ),
  AppComponent(
    title: S.current.favoritesContent,
    widget: const AzkarBookmarks(),
  ),
  AppComponent(
    title: S.current.favoritesZikr,
    widget: const FavouriteZikr(),
  ),
];
