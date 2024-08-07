import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/extensions/string_extension.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/core/repos/app_data.dart';
import 'package:hisnelmoslem/src/core/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/src/core/values/app_dashboard.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/alarm.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/repository/alarm_database_helper.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/home/data/repository/azkar_database_helper.dart';
import 'package:hisnelmoslem/src/features/quran/presentation/controller/quran_controller.dart';
import 'package:hisnelmoslem/src/features/quran/presentation/screens/quran_read_page.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/screens/azkar_read_card.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/screens/azkar_read_page.dart';
import 'package:intl/intl.dart';

class DashboardController extends GetxController
    with GetSingleTickerProviderStateMixin {
  /* *************** Variables *************** */
  //
  int currentIndex = 0;
  bool isLoading = false;

  //
  bool isSearching = false;

  //
  TextEditingController searchController = TextEditingController();

  //
  final ScrollController fehrsScrollController = ScrollController();
  final ScrollController bookmarksScrollController = ScrollController();
  late TabController tabController;

  //
  List<DbTitle> favouriteTitle = <DbTitle>[];
  List<DbTitle> allTitle = <DbTitle>[];
  List<DbTitle> searchedTitle = <DbTitle>[];
  List<DbAlarm> alarms = <DbAlarm>[];
  List<DbContent> favouriteContent = <DbContent>[];

  // List<DbContent> zikrContent = <DbContent>[];
  //
  ZoomDrawerController zoomDrawerController = ZoomDrawerController();

  /* *************** Controller life cycle *************** */
  //
  @override
  Future<void> onInit() async {
    super.onInit();

    ///

    Intl.defaultLocale = Get.locale!.countryCode;
    //
    isLoading = true;

    //
    update();

    //
    await getAllListsReady();

    tabController = TabController(vsync: this, length: appDashboardItem.length);
    isLoading = false;
    //
    update();
  }

  //
  @override
  void onClose() {
    super.onClose();
    searchController.dispose();
    fehrsScrollController.dispose();
    bookmarksScrollController.dispose();
  }

  /* *************** Functions *************** */
  //
  Future<void> getAllListsReady() async {
    /* ***** Get All Titles ***** */
    await azkarDatabaseHelper.getAllTitles().then((value) {
      allTitle = value;
    });

    hisnPrint("allTitle: ${allTitle.length}");

    /* ***** Get All Favourite Titles ***** */
    await azkarDatabaseHelper.getAllFavoriteTitles().then((value) {
      favouriteTitle = value;
    });
    hisnPrint("favouriteTitle: ${favouriteTitle.length}");

    /* ***** Get All favorite content ***** */
    await getFavouriteContent();

    /* ***** Get All Alarms ***** */
    await alarmDatabaseHelper.getAlarms().then((value) {
      alarms = value;
    });
    hisnPrint("alarms: ${alarms.length}");

    searchedTitle = allTitle;

    /**
     * Update isLoading to start show views and widgets
     */
    isLoading = false;
    update();
  }

  //
  Future<void> getFavouriteContent() async {
    await azkarDatabaseHelper.getFavouriteContents().then((value) {
      favouriteContent = value;
    });
    update();
  }

  ///
  void onNotificationClick(String payload) {
    /// go to quran page if clicked
    if (payload == "الكهف") {
      transitionAnimation.fromBottom2Top(
        context: Get.context!,
        goToPage: const QuranReadPage(
          surahName: SurahNameEnum.alKahf,
        ),
      );
    }

    /// ignore constant alarms if clicked
    else if (payload == "555" || payload == "666") {
    }

    /// go to zikr page if clicked
    else {
      final int pageIndex = int.parse(payload);
      //
      if (AppData.instance.isCardReadMode) {
        transitionAnimation.fromBottom2Top(
          context: Get.context!,
          goToPage: AzkarReadCard(index: pageIndex),
        );
      } else {
        transitionAnimation.fromBottom2Top(
          context: Get.context!,
          goToPage: AzkarReadPage(index: pageIndex),
        );
      }
    }
  }

  //
  void searchZikr() {
    isSearching = true;
    //
    update();
    if (searchController.text.isEmpty || searchController.text == "") {
      searchedTitle = allTitle;
    } else {
      searchedTitle = allTitle.where((zikr) {
        final zikrTitle = zikr.name.removeDiacritics;
        return zikrTitle.contains(searchController.text);
      }).toList();
    }
    //
    update();
  }

  //
  Future<void> addContentToFavourite(DbContent dbContent) async {
    //
    await azkarDatabaseHelper.addContentToFavourite(dbContent: dbContent);
    //
    await getFavouriteContent();
    //
    update();
  }

  //
  Future<void> removeContentFromFavourite(DbContent dbContent) async {
    //
    await azkarDatabaseHelper.removeContentFromFavourite(dbContent: dbContent);
    //
    await getFavouriteContent();
    //
    update();
  }

  ///
  void toggleDrawer() {
    zoomDrawerController.toggle?.call();
    update();
  }

/* ****************************** */
}
