import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/src/core/functions/get_snackbar.dart';
import 'package:hisnelmoslem/src/core/functions/show_toast.dart';
import 'package:hisnelmoslem/src/core/shared/dialogs/yes_no_dialog.dart';
import 'package:hisnelmoslem/src/core/utils/tally_database_helper.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/settings/presentation/components/sound_manager/sounds_manager_controller.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/components/dialogs/tally_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TallyController extends GetxController {
  /* *************** Variables *************** */

  ///
  late final SharedPreferences prefs;

  ///
  int get counter {
    if (currentDBTally != null) {
      if (isShuffleModeOn) {
        int temp = 0;
        for (final element in allTally) {
          temp += element.count;
        }
        return temp;
      }
      return currentDBTally!.count;
    } else {
      return 0;
    }
  }

  double get circleValue {
    if (isShuffleModeOn) {}
    return counter.toDouble() -
        (counter ~/ circleResetEvery) * circleResetEvery;
  }

  int? get circleValueTimes {
    return counter ~/ circleResetEvery;
  }

  ///
  int get circleResetEvery {
    if (isShuffleModeOn) {
      return 33;
    }
    return currentDBTally!.countReset;
  }

  ///
  static const _volumeBtnChannel = MethodChannel("volume_button_channel");

  ///
  List<DbTally> allTally = <DbTally>[];
  bool isLoading = false;

  ///
  DbTally? get currentDBTally {
    for (final DbTally item in allTally) {
      if (item.isActivated) {
        return item;
      }
    }
    return null;
  }

  /* *************** Controller life cycle *************** */
  //
  @override
  void onInit() {
    super.onInit();

    ///
    checkSharedPrefs();

    ///
    getAllListsReady();

    ///
    // getData();

    ///
    _volumeBtnChannel.setMethodCallHandler((call) {
      if (call.method == "volumeBtnPressed") {
        if (call.arguments == "VOLUME_DOWN_UP") {
          // minusCounter();
          increaseDBCounter();
        } else if (call.arguments == "VOLUME_UP_UP") {
          // incrementCounter();
          // decreaseDBCounter();
          increaseDBCounter();
        }
      }

      return Future.value();
    });

    update();
  }

  @override
  void onClose() {
    super.onClose();

    ///
    _volumeBtnChannel.setMethodCallHandler(null);
  }

  /* *************** Functions *************** */
  //

  Future<void> getAllListsReady() async {
    isLoading = true;
    update();

    await tallyDatabaseHelper.getAllTally().then((value) {
      allTally = value;
    });

    isLoading = false;
    update();
  }

  void updateDBTallyToView({required DbTally dbTally}) {
    for (DbTally item in allTally) {
      if (item.id == dbTally.id) {
        item = dbTally;
        update();
      }
    }
  }

  Future<void> checkSharedPrefs() async {
    prefs = await SharedPreferences.getInstance();

    if (prefs.getString('counter') != null) {
      if (prefs.getString('counter') != "0") {
        final int count = int.parse(prefs.getString('counter')!);
        final DbTally dbTally = DbTally(
          title: "عام",
          count: count,
          created: DateTime.now(),
          lastUpdate: DateTime.now(),
        );
        await tallyDatabaseHelper.addNewTally(dbTally: dbTally);
        prefs.setString('counter', "0");
        getSnackbar(
          title: "رسالة من السُبحة",
          message: "أهلا بك في التحديث الجديد",
        );
        getAllListsReady();
        update();
      }
    }
  }

  Future<void> activateTally(DbTally dbTally) async {
    await toggleActivateTally(dbTally);
  }

  Future<void> toggleActivateTally(DbTally dbTally) async {
    for (final DbTally tally in allTally) {
      if (dbTally.id == tally.id) {
        dbTally.isActivated = true;
        tally.isActivated = true;
      } else {
        tally.isActivated = false;
      }
      await tallyDatabaseHelper.updateTally(dbTally: tally, updateTime: false);
    }
    update();
  }

  Future<void> deactivateTally({required DbTally dbTally}) async {
    dbTally.isActivated = false;
    await tallyDatabaseHelper.updateTally(dbTally: dbTally, updateTime: false);
    updateDBTallyToView(dbTally: dbTally);
  }

  Future<void> deactivateAllTally() async {
    for (final DbTally dbTally in allTally) {
      dbTally.isActivated = false;
      await tallyDatabaseHelper.updateTally(
        dbTally: dbTally,
        updateTime: false,
      );
    }
  }

  /// CURD
  Future<void> createNewTally() async {
    await showDialog(
      barrierDismissible: true,
      context: Get.context!,
      builder: (BuildContext context) {
        return TallyDialog(
          dbTally: DbTally(),
          isToEdit: false,
          onSubmit: (value) async {
            await tallyDatabaseHelper.addNewTally(dbTally: value);
            getAllListsReady();
            update();
          },
        );
      },
    );
  }

  Future<void> updateTallyById(DbTally dbTally) async {
    await showDialog(
      barrierDismissible: true,
      context: Get.context!,
      builder: (BuildContext context) {
        return TallyDialog(
          isToEdit: true,
          dbTally: dbTally,
          onSubmit: (value) async {
            await tallyDatabaseHelper.updateTally(
              dbTally: value,
              updateTime: false,
            );
            updateDBTallyToView(dbTally: value);
          },
        );
      },
    );
  }

  Future<void> increaseDBCounter() async {
    if (currentDBTally != null) {
      //
      if (circleValue == circleResetEvery - 1) {
        SoundsManagerController().playZikrDoneEffects();
      } else {
        SoundsManagerController().playTallyEffects();
      }

      currentDBTally!.count += 1;
      await tallyDatabaseHelper.updateTally(
        dbTally: currentDBTally!,
        updateTime: true,
      );
      update();

      shuffle();
    }
  }

  Future<void> decreaseDBCounter() async {
    if (currentDBTally != null) {
      currentDBTally!.count -= 1;
      await tallyDatabaseHelper.updateTally(
        dbTally: currentDBTally!,
        updateTime: true,
      );
      update();
    }
  }

  void resetDBCounter() {
    if (currentDBTally != null) {
      showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: transparent,
        context: Get.context!,
        builder: (BuildContext context) {
          return YesOrNoDialog(
            msg: "your progress will be deleted and you can't undo that".tr,
            onYes: () async {
              currentDBTally!.count = 0;
              await tallyDatabaseHelper.updateTally(
                dbTally: currentDBTally!,
                updateTime: true,
              );
              update();
            },
          );
        },
      );
    }
  }

  void nextCounter() {
    if (currentDBTally == null) return;

    final index = allTally.indexOf(currentDBTally!);
    if (index == -1) return;

    final newIndex = (index + 1) % allTally.length;
    activateTally(allTally[newIndex]);
  }

  void previousCounter() {
    if (currentDBTally == null) return;

    final index = allTally.indexOf(currentDBTally!);
    if (index == -1) return;

    final newIndex = (index - 1) % allTally.length;
    activateTally(allTally[newIndex]);
  }

  void deleteTallyById(DbTally dbTally) {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: transparent,
      context: Get.context!,
      builder: (BuildContext context) {
        return YesOrNoDialog(
          msg: "This counter will be deleted.".tr,
          onYes: () async {
            await tallyDatabaseHelper.deleteTally(dbTally: dbTally);
            getAllListsReady();
            // if (currentDBTally == dbTally) {
            //   currentDBTally = null;
            // }
            update();
          },
        );
      },
    );
  }

  void resetAllTally() {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: transparent,
      context: Get.context!,
      builder: (BuildContext context) {
        return YesOrNoDialog(
          msg: "Reset all counters?.".tr,
          onYes: () async {
            for (var i = 0; i < allTally.length; i++) {
              await tallyDatabaseHelper.updateTally(
                dbTally: allTally[i]..count = 0,
                updateTime: true,
              );
            }
            await getAllListsReady();
            update();
          },
        );
      },
    );
  }

  void tallySettings() {
    if (currentDBTally != null) {
      updateTallyById(currentDBTally!);
    }
  }

  /* *************** Variables *************** */
  final box = GetStorage();
  bool get isShuffleModeOn => box.read('is_tally_shuffle_mode_on') ?? false;
  void toggleShuffleMode() {
    box.write('is_tally_shuffle_mode_on', !isShuffleModeOn);
    if (isShuffleModeOn) {
      showToast(msg: "Shuffle Mode Activated".tr);
    } else {
      showToast(msg: "Shuffle Mode Deactivated".tr);
    }
    update();
  }

  void shuffle() {
    if (isShuffleModeOn && allTally.length > 1) {
      final Random rng = Random();
      activateTally(allTally[rng.nextInt(allTally.length)]);
    }
  }
}
