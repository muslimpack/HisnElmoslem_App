import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/controllers/app_data_controllers.dart';
import 'package:hisnelmoslem/models/alarm.dart';
import 'package:hisnelmoslem/models/zikr_content.dart';
import 'package:hisnelmoslem/models/zikr_title.dart';
import 'package:hisnelmoslem/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/utils/alarm_database_helper.dart';
import 'package:hisnelmoslem/utils/azkar_database_helper.dart';
import 'package:hisnelmoslem/utils/notification_manager.dart';
import 'package:hisnelmoslem/views/screens/azkar_read_card.dart';
import 'package:hisnelmoslem/views/screens/azkar_read_page.dart';
import 'package:hisnelmoslem/views/screens/quran_read_page.dart';
import '../models/received_notification.dart';
import '../shared/constants/constant.dart';

class DashboardController extends GetxController {
  /* *************** Variables *************** */
  //
  String? payload = "";
  //
  int currentIndex = 0;
  bool isLoading = false;
  //
  bool isSearching = false;
  //
  TextEditingController searchController = TextEditingController();
  late TabController tabController;
  //
  final ScrollController fehrsScrollController = ScrollController();
  final ScrollController bookmarksScrollController = ScrollController();
  //
  final AppDataController appDataController = Get.put(AppDataController());
  //
  List<DbTitle> favouriteTitle = <DbTitle>[];
  List<DbTitle> allTitle = <DbTitle>[];
  List<DbTitle> searchedTitle = <DbTitle>[];
  List<DbAlarm> alarms = <DbAlarm>[];
  List<DbContent> favouriteConent = <DbContent>[];
  // List<DbContent> zikrContent = <DbContent>[];
  //

  /* *************** Controller life cycle *************** */
  //
  @override
  void onInit() async {
    super.onInit();

    //
    isLoading = true;

    //
    update();

    //
    await getAllListsReady();

    //Manage Notification feedback
    if (payload != "" && payload != null) {
      onNotificationClick(payload!);
    }

    localNotifyManager.setOnNotificationReceive(onNotificationReceive);
    localNotifyManager.setOnNotificationClick(onNotificationClick);

    isLoading = false;
    //
    update();
  }

  //
  @override
  void onClose() {
    super.onClose();
    searchController.dispose();
    tabController.dispose();
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

  //
  onNotificationReceive(ReceivedNotification notification) {}

  //
  onNotificationClick(String payload) {
    debugPrint('payload = $payload');

    /// go to quran page if clicked
    if (payload == "الكهف") {
      transitionAnimation.fromBottom2Top(
          context: Get.context!, goToPage: QuranReadPage());
    }

    /// ignore constant alarms if clicked
    else if (payload == "555" || payload == "666") {
    }

    /// go to zikr page if clicked
    else {
      int? pageIndex = int.parse(payload);
      //
      if (appDataController.isCardReadMode) {
        transitionAnimation.fromBottom2Top(
            context: Get.context!, goToPage: AzkarReadCard(index: pageIndex));
      } else {
        transitionAnimation.fromBottom2Top(
            context: Get.context!, goToPage: AzkarReadPage(index: pageIndex));
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
      debugPrint("Controller.searchTxt.isEmpty || controller.searchTxt == ");
    } else {
      debugPrint("else");
      searchedTitle = allTitle.where((zikr) {
        var zikrTitle = zikr.name.replaceAll(
            new RegExp(String.fromCharCodes(arabicTashkelChar)), "");
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
  /* ****************************** */
}
