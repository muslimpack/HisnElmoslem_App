import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/features/dashboard/data/models/app_component.dart';
import 'package:hisnelmoslem/src/features/dashboard/presentation/components/pages/bookmarks.dart';
import 'package:hisnelmoslem/src/features/dashboard/presentation/components/pages/favorite_zikr.dart';
import 'package:hisnelmoslem/src/features/dashboard/presentation/components/pages/fehrs.dart';

final List<AppComponent> appDashboardItem = [
  AppComponent(
    title: S.current.index,
    widget: const AzkarFehrs(),
  ),
  AppComponent(
    title: S.current.favorites_content,
    widget: const AzkarBookmarks(),
  ),
  AppComponent(
    title: S.current.favorites_zikr,
    widget: const FavouriteZikr(),
  ),
];
