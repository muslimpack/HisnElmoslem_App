import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/features/alarm/data/data_source/alarm_database_helper.dart';
import 'package:hisnelmoslem/src/features/alarm/data/models/alarm.dart';

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
  Future<void> getAllListsReady() async {
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
