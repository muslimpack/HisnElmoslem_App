import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/features/effects_manager/presentation/controller/sounds_manager_controller.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/home/data/repository/azkar_database_helper.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:wakelock/wakelock.dart';

class AzkarReadCardController extends GetxController {
  /* *************** Constructor *************** */
  //
  final int index;

  AzkarReadCardController({required this.index});

  /* *************** Variables *************** */
  //
  final vReadScaffoldKey = GlobalKey<ScaffoldState>();
  bool? isLoading = true;
  double? totalProgress = 0.0;
  int zikrCountSum = 0;
  double? totalProgressForEverySingle = 0.0;

  //
  List<DbContent> zikrContent = <DbContent>[];
  DbTitle? zikrTitle;

  //

  /* *************** Controller life cycle *************** */
  //
  @override
  Future<void> onInit() async {
    super.onInit();

    //
    Wakelock.enable();

    //
    await getReady();
    getEveryZikrCount();
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
  Future<void> getReady() async {
    await azkarDatabaseHelper
        .getTitleById(id: index)
        .then((value) => zikrTitle = value);

    await azkarDatabaseHelper
        .getContentsByTitleId(titleId: index)
        .then((value) => zikrContent = value);

    update();
  }

  int decreaseCount(int counter, int index) {
    int tempCounter = counter;
    if (tempCounter > 0) {
      tempCounter--;

      zikrContent[index].count = tempCounter;

      ///
      SoundsManagerController().playTallyEffects();
      if (tempCounter == 0) {
        SoundsManagerController().playZikrDoneEffects();
      } else if (tempCounter < 0) {
        tempCounter = 0;
      }
    }

    ///
    checkProgress();
    checkProgressForSingle();

    return counter;
  }

  void checkProgress() {
    int totalNum = 0;
    int done = 0;
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

  void checkProgressForSingle() {
    int done = 0;
    for (var i = 0; i < zikrContent.length; i++) {
      done += zikrContent[i].count;
    }
    totalProgressForEverySingle = (zikrCountSum - done) / zikrCountSum;

    update();
  }

  void getEveryZikrCount() {
    int sum = 0;

    for (var i = 0; i < zikrContent.length; i++) {
      sum += zikrContent[i].count;
    }
    zikrCountSum = sum;
    update();
  }
}
