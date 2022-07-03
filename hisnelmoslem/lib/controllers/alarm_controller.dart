import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/models/alarm.dart';
import 'package:hisnelmoslem/utils/alarm_database_helper.dart';

class AlarmsPageController extends GetxController {
  /* *************** Variables *************** */
  //
  ScrollController alarmScrollController = ScrollController();

  //
  List<DbAlarm> alarms = <DbAlarm>[];
  bool isLoading = false;

  //

  /* *************** Controller life cycle *************** */
  //

  @override
  void onInit() {
    super.onInit();
    getAllListsReady();
  }

  @override
  void onClose() {
    super.onClose();
    alarmScrollController.dispose();
  }

  /* *************** Functions *************** */

  ///
  getAllListsReady() async {
    alarms = <DbAlarm>[];

    isLoading = true;
    update();

    await alarmDatabaseHelper.getAlarms().then((value) {
      alarms = value;
    });

    isLoading = false;
    update();
  }
}
