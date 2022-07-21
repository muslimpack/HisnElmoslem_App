import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/app/data/models/tally.dart';
import 'package:hisnelmoslem/core/values/constant.dart';
import 'package:hisnelmoslem/app/shared/dialogs/yes_no_dialog.dart';
import 'package:hisnelmoslem/app/shared/functions/get_snackbar.dart';
import 'package:hisnelmoslem/core/utils/tally_database_helper.dart';
import 'package:hisnelmoslem/app/modules/tally/dialogs/add_tally_dialog.dart';
import 'package:hisnelmoslem/app/modules/tally/dialogs/edit_tally_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../sound_manager/sounds_manager_controller.dart';

class TallyController extends GetxController {
  /* *************** Variables *************** */

  ///
  final Future<SharedPreferences> _sprefs = SharedPreferences.getInstance();

  ///
  int get counter {
    if (currentDBTally != null) {
      return currentDBTally!.count;
    } else {
      return 0;
    }
  }

  double get circval =>
      (counter.toDouble() - (counter ~/ circleResetEvery) * circleResetEvery);

  int? get circvaltimes => counter ~/ circleResetEvery;

  ///
  int get circleResetEvery => currentDBTally!.countReset;

  ///
  static const _volumeBtnChannel = MethodChannel("volume_button_channel");

  ///
  List<DbTally> allTally = <DbTally>[];
  bool isLoading = false;

  ///
  DbTally? get currentDBTally {
    for (DbTally item in allTally) {
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

      return Future.value(null);
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

  void getAllListsReady() async {
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

  checkSharedPrefs() async {
    final SharedPreferences prefs = await _sprefs;
    if (prefs.getString('counter') != null) {
      if (prefs.getString('counter') != "0") {
        int count = int.parse((prefs.getString('counter')!));
        DbTally dbTally = DbTally(
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

  activateTally(DbTally dbTally) async {
    if (currentDBTally != null) {
      currentDBTally!.isActivated = false;
      await deactivateAllTally();
      // updateDBTallyToView(dbTally: currentDBTally!);
    }
    dbTally.isActivated = true;
    await tallyDatabaseHelper.updateTally(dbTally: dbTally, updateTime: false);
    updateDBTallyToView(dbTally: dbTally);
    // getAllListsReady();
    // currentDBTally = dbTally;

    update();
  }

  deactivateCurrentTally() async {
    if (currentDBTally != null) {
      deactivateTally(dbTally: currentDBTally!);
    }
  }

  deactivateTally({required DbTally dbTally}) async {
    dbTally.isActivated = false;

    await tallyDatabaseHelper.updateTally(dbTally: dbTally, updateTime: false);
    await updateDBTallyToView(dbTally: dbTally);

    update();
  }

  deactivateAllTally() async {
    for (DbTally dbTally in allTally) {
      await tallyDatabaseHelper.updateTally(
          dbTally: dbTally, updateTime: false);
      dbTally.isActivated = false;
      await tallyDatabaseHelper.updateTally(
          dbTally: dbTally, updateTime: false);
    }
  }

  /// CURD
  createNewTally() async {
    await showDialog(
      barrierDismissible: true,
      context: Get.context!,
      builder: (BuildContext context) {
        return AddTallyDialog(
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
        return EditTallyDialog(
          dbTally: dbTally,
          onSubmit: (value) async {
            await tallyDatabaseHelper.updateTally(
                dbTally: value, updateTime: false);
            await updateDBTallyToView(dbTally: value);
            update();
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
      }
      // int index = allTally.indexOf(currentDBTally!);
      currentDBTally!.count += 1;
      await tallyDatabaseHelper.updateTally(
          dbTally: currentDBTally!, updateTime: true);
      updateDBTallyToView(dbTally: currentDBTally!);
      // currentDBTally = allTally[index];
      SoundsManagerController().playTallyEffects();

      update();
    }
  }

  decreaseDBCounter() async {
    if (currentDBTally != null) {
      currentDBTally!.count -= 1;
      await tallyDatabaseHelper.updateTally(
          dbTally: currentDBTally!, updateTime: true);

      updateDBTallyToView(dbTally: currentDBTally!);

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
              msg:
                  "سيتم حذف تقدمك في هذا الذكر\nهل أنت متأكد أنك تريد القيام بهذا؟",
              onYes: () async {
                currentDBTally!.count = 0;
                await tallyDatabaseHelper.updateTally(
                    dbTally: currentDBTally!, updateTime: true);
                updateDBTallyToView(dbTally: currentDBTally!);

                update();
              },
            );
          });
    }
  }

  deleteTallyById(DbTally dbTally) {
    showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: transparent,
        context: Get.context!,
        builder: (BuildContext context) {
          return YesOrNoDialog(
            msg:
                "سيتم حذف هذا الذكر بما فيه من انجاز\nهل أنت متأكد أنك تريد القيام بهذا؟",
            onYes: () async {
              await tallyDatabaseHelper.deleteTally(dbTally: dbTally);
              getAllListsReady();
              // if (currentDBTally == dbTally) {
              //   currentDBTally = null;
              // }
              update();
            },
          );
        });
  }

  tallySettings() {
    if (currentDBTally != null) {
      updateTallyById(currentDBTally!);
    }
  }
}
