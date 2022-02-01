import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/models/alarm.dart';
import 'package:hisnelmoslem/models/zikr_content.dart';
import 'package:hisnelmoslem/models/zikr_title.dart';
import 'package:hisnelmoslem/utils/alarm_database_helper.dart';
import 'package:hisnelmoslem/utils/azkar_database_helper.dart';
import 'package:hisnelmoslem/utils/notification_manager.dart';

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
  List<DbTitle> favouriteTitle = <DbTitle>[];
  List<DbTitle> allTitle = <DbTitle>[];
  List<DbTitle> searchedTitle = <DbTitle>[];
  List<DbAlarm> alarms = <DbAlarm>[];
  List<DbContent> zikrContent = <DbContent>[];
  //

  /* *************** Controller life cycle *************** */
  //
  @override
  void onInit() {
    super.onInit();
    //
    isLoading = true;
    //
    update();
    //
    getAllListsReady();
    //
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);

    //Manage Notification feedback

    if (payload != "") {
      onNotificationClick(payload!);
    }

    localNotifyManager.setOnNotificationReceive(onNotificationReceive);
    localNotifyManager.setOnNotificationClick(onNotificationClick);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);

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

    favouriteTitle = allTitle.where((item) => item.favourite == 1).toList();

    /* ***** Get All Alarms ***** */
    await alarmDatabaseHelper.getAlarms().then((value) {
      alarms = value;
    });

    /* ***** Get All favoutie content ***** */
    await azkarDatabaseHelper
        .getFavouriteContent()
        .then((value) => zikrContent = value);

    /* 
    ***** Update is loading to start show views and widgets
    ***** Update() is like SetState() in statefulWidget
    ***** */
    isLoading = false;
    update();
  }

  //
  onNotificationReceive(ReceiveNotification notification) {}
  //
  onNotificationClick(String payload) {
    // TODO solve context issue to route to zikr  screen when click notification
    debugPrint('payload = $payload');
    if (payload == "الكهف") {
      // transitionAnimation.fromBottom2Top(
      //     context: context, goToPage: QuranReadPage());
    } else if (payload == "555" || payload == "777") {
    } else {
      int? pageIndex = int.parse(payload);
      debugPrint('pageIndex = $pageIndex');

      debugPrint('Will open = $pageIndex');
      debugPrint("pageIndex: " + pageIndex.toString());
      // transitionAnimation.fromBottom2Top(
      //     context: context, goToPage: AzkarReadPage(index: pageIndex));
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
            new RegExp(String.fromCharCodes([
              1617,
              124,
              1614,
              124,
              1611,
              124,
              1615,
              124,
              1612,
              124,
              1616,
              124,
              1613,
              124,
              1618
            ])),
            "");
        return zikrTitle.contains(searchController.text);
      }).toList();
    }
    //
    update();
  }
  /* ****************************** */
}
