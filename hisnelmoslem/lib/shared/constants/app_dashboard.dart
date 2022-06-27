import 'package:hisnelmoslem/models/app_component.dart';
import 'package:hisnelmoslem/views/dashboard/pages/bookmarks.dart';
import 'package:hisnelmoslem/views/dashboard/pages/favorite_zikr.dart';
import 'package:hisnelmoslem/views/dashboard/pages/fehrs.dart';

final List<AppComponent> appDashboardItem = [
  AppComponent(
    title: "الفهرس",
    widget: const AzkarFehrs(),
  ),
  AppComponent(
    title: "المفضلة",
    widget: const AzkarBookmarks(),
  ),
  AppComponent(
    title: "مفضلة الأذكار",
    widget: const FavouriteZikr(),
  ),
];
