import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import "package:hisnelmoslem/app/data/models/models.dart";
import 'package:hisnelmoslem/app/modules/sound_manager/sounds_manager_controller.dart';
import 'package:hisnelmoslem/app/modules/tally/dialogs/tally_dialog.dart';
import 'package:hisnelmoslem/app/shared/dialogs/yes_no_dialog.dart';
import 'package:hisnelmoslem/app/shared/functions/get_snackbar.dart';
import 'package:hisnelmoslem/app/shared/functions/show_toast.dart';
import 'package:hisnelmoslem/core/utils/tally_database_helper.dart';
import 'package:hisnelmoslem/core/values/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TallyController extends GetxController {
  /* *************** Variables *************** */

  ///
  final Future<SharedPreferences> _sprefs = SharedPreferences.getInstance();

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

  double get circval {
    if (isShuffleModeOn) {}
    return counter.toDouble() -
        (counter ~/ circleResetEvery) * circleResetEvery;
  }

  int? get circvaltimes {
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

  updateDBTallyToView({required DbTally dbTally}) {
    for (DbTally item in allTally) {
      if (item.id == dbTally.id) {
        item = dbTally;
        update();
      }
    }
  }

  Future<void> checkSharedPrefs() async {
    final SharedPreferences prefs = await _sprefs;
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

  deactivateTally({required DbTally dbTally}) async {
    dbTally.isActivated = false;
    await tallyDatabaseHelper.updateTally(dbTally: dbTally, updateTime: false);
    await updateDBTallyToView(dbTally: dbTally);
  }

  deactivateAllTally() async {
    for (final DbTally dbTally in allTally) {
      dbTally.isActivated = false;
      await tallyDatabaseHelper.updateTally(
        dbTally: dbTally,
        updateTime: false,
      );
    }
  }

  /// CURD
  createNewTally() async {
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

  updateTallyById(DbTally dbTally) async {
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
            await updateDBTallyToView(dbTally: value);
          },
        );
      },
    );
  }

  increaseDBCounter() async {
    if (currentDBTally != null) {
      //
      if (circval == circleResetEvery - 1) {
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

  decreaseDBCounter() async {
    if (currentDBTally != null) {
      currentDBTally!.count -= 1;
      await tallyDatabaseHelper.updateTally(
        dbTally: currentDBTally!,
        updateTime: true,
      );
      update();
    }
  }

  resetDBCounter() {
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

  deleteTallyById(DbTally dbTally) {
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

  tallySettings() {
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
