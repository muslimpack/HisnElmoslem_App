import 'package:get/get.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/pages/bookmarks.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/pages/favorite_zikr.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/pages/fehrs.dart';
import 'package:hisnelmoslem/src/features/settings/data/models/app_component.dart';

final List<AppComponent> appDashboardItem = [
  AppComponent(
    title: "index".tr,
    widget: const AzkarFehrs(),
  ),
  AppComponent(
    title: "favorites content".tr,
    widget: const AzkarBookmarks(),
  ),
  AppComponent(
    title: "favorites zikr".tr,
    widget: const FavouriteZikr(),
  ),
];
