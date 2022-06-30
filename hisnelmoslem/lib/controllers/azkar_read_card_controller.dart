import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/models/zikr_content.dart';
import 'package:hisnelmoslem/models/zikr_title.dart';
import 'package:hisnelmoslem/utils/azkar_database_helper.dart';
import 'package:wakelock/wakelock.dart';
import 'sounds_manager_controller.dart';

class AzkarReadCardController extends GetxController {
  /* *************** Constractor *************** */
  //
  final int index;
  AzkarReadCardController({required this.index});

  /* *************** Variables *************** */
  //
  final vReadScaffoldKey = GlobalKey<ScaffoldState>();
  bool? isLoading = true;
  double? totalProgress = 0.0;
  //
  List<DbContent> zikrContent = <DbContent>[];
  DbTitle? zikrTitle;
  //

  /* *************** Controller life cycle *************** */
  //
  @override
  void onInit() async {
    super.onInit();

    //
    Wakelock.enable();

    //
    await getReady();

    //
    isLoading = false;
    //
    update();
  }

  //
  @override
  void onClose() {
    super.onClose();
    Wakelock.disable();
  }

  /* *************** Functions *************** */

  /// Load all lists from its databases
  getReady() async {
    await azkarDatabaseHelper
        .getTitleById(id: index)
        .then((value) => zikrTitle = value);

    await azkarDatabaseHelper
        .getContentsByTitleId(titleId: index)
        .then((value) => zikrContent = value);

    update();
  }

  checkProgress() {
    int totalNum = 0, done = 0;
    totalNum = zikrContent.length;
    for (var i = 0; i < zikrContent.length; i++) {
      if (zikrContent[i].count == 0) {
        done++;
      }
    }
    totalProgress = done / totalNum;
    if (totalProgress == 1) {
      ///
      SoundsManagerController().playAllAzkarFinishedEffects();
    }
    update();
  }
}
