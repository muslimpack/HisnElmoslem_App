import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/app/data/app_data.dart';
import "package:hisnelmoslem/app/data/models/models.dart";
import 'package:hisnelmoslem/app/modules/azkar_card.dart/azkar_read_card.dart';
import 'package:hisnelmoslem/app/modules/azkar_page/azkar_read_page.dart';
import 'package:hisnelmoslem/app/modules/quran/quran_controller.dart';
import 'package:hisnelmoslem/app/modules/quran/quran_read_page.dart';
import 'package:hisnelmoslem/app/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/core/themes/theme_services.dart';
import 'package:hisnelmoslem/core/utils/alarm_database_helper.dart';
import 'package:hisnelmoslem/core/utils/azkar_database_helper.dart';
import 'package:hisnelmoslem/core/values/app_dashboard.dart';
import 'package:hisnelmoslem/core/values/constant.dart';
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
  List<DbContent> favouriteConent = <DbContent>[];

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
  getAllListsReady() async {
    /* ***** Get All Titles ***** */
    await azkarDatabaseHelper.getAllTitles().then((value) {
      allTitle = value;
    });

    /* ***** Get All Favourite Titles ***** */
    await azkarDatabaseHelper.getAllFavoriteTitles().then((value) {
      favouriteTitle = value;
    });

    /* ***** Get All favoutie content ***** */
    await getFavouriteContent();

    /* ***** Get All Alarms ***** */
    await alarmDatabaseHelper.getAlarms().then((value) {
      alarms = value;
    });

    searchedTitle = allTitle;

    /**
     * Update isLoading to start show views and widgets
     */
    isLoading = false;
    update();
  }

  //
  getFavouriteContent() async {
    await azkarDatabaseHelper.getFavouriteContents().then((value) {
      favouriteConent = value;
    });
    update();
  }

  ///
  onNotificationClick(String payload) {
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
      if (appData.isCardReadMode) {
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
  searchZikr() {
    isSearching = true;
    //
    update();
    if (searchController.text.isEmpty || searchController.text == "") {
      searchedTitle = allTitle;
    } else {
      searchedTitle = allTitle.where((zikr) {
        final zikrTitle = zikr.name
            .replaceAll(RegExp(String.fromCharCodes(arabicTashkelChar)), "");
        return zikrTitle.contains(searchController.text);
      }).toList();
    }
    //
    update();
  }

  //
  addContentToFavourite(DbContent dbContent) async {
    //
    await azkarDatabaseHelper.addContentToFavourite(dbContent: dbContent);
    //
    await getFavouriteContent();
    //
    update();
  }

  //
  removeContentFromFavourite(DbContent dbContent) async {
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

  ///
  void toggleTheme() {
    ThemeServices.changeThemeMode();
    Get.forceAppUpdate();
    update();
  }
/* ****************************** */
}
