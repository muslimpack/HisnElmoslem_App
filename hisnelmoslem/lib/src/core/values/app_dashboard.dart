import 'package:get/get.dart';
import "package:hisnelmoslem/app/data/models/models.dart";
import 'package:hisnelmoslem/src/features/home/presentation/components/pages/bookmarks.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/pages/favorite_zikr.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/pages/fehrs.dart';

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
