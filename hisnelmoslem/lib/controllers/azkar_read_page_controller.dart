import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/Shared/functions/get_snackbar.dart';
import 'package:wakelock/wakelock.dart';
import '../models/zikr_content.dart';
import '../models/zikr_title.dart';
import '../utils/azkar_database_helper.dart';
import 'sounds_manager_controller.dart';

class AzkarReadPageController extends GetxController {
  /* *************** Constractor *************** */
  //
  final int index;
  AzkarReadPageController({required this.index});

  /* *************** Variables *************** */
  //
  bool isLoading = true;
  //
  //
  final hReadScaffoldKey = GlobalKey<ScaffoldState>();
  PageController pageController = PageController(initialPage: 0);
  //
  List<DbContent> zikrContent = <DbContent>[];
  DbTitle? zikrTitle;
  //
  int currentPage = 0;
  double? totalProgress = 0.0;
  //
  static const _volumeBtnChannel = MethodChannel("volume_button_channel");
  String? text = "";
  String? source = "";
  String? fadl = "";
  int? cardnum = 0;
  //

  /* *************** Controller life cycle *************** */
  //
  @override
  void onInit() async {
    super.onInit();
    //
    Wakelock.enable();
//
    _volumeBtnChannel.setMethodCallHandler((call) {
      if (call.method == "volumeBtnPressed") {
        if (call.arguments == "VOLUME_DOWN_UP" ||
            call.arguments == "VOLUME_UP_UP") {
          decreaseCount();
        }
        if (call.arguments == "MEDIA_BUTTON_DOWN") {
          getSnackbar(message: "MEDIA_BUTTON_DOWN");
        }
      }

      return Future.value(null);
    });

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
    pageController.dispose();
    _volumeBtnChannel.setMethodCallHandler(null);
  }

  /* *************** Functions *************** */
  //

  getReady() async {
    await azkarDatabaseHelper
        .getTitleById(id: index)
        .then((value) => zikrTitle = value);
    //
    await azkarDatabaseHelper
        .getContentsByTitleId(titleId: index)
        .then((value) => zikrContent = value);

    isLoading = false;
    update();
  }

  onPageViewChange(int page) {
    currentPage = page;
    update();
  }

  decreaseCount() {
    int _counter = zikrContent[currentPage].count;
    if (_counter == 0) {
      HapticFeedback.vibrate();
      SoundsManagerController().playZikrDoneSound();
    } else {
      _counter--;

      zikrContent[currentPage].count = ((zikrContent[currentPage].count) - 1);

      ///
      SoundsManagerController().playTallySound();
      if (_counter > 0) {
      } else if (_counter == 0) {
        ///
        HapticFeedback.vibrate();

        ///
        SoundsManagerController().playZikrDoneSound();
        SoundsManagerController().playTransitionSound();

        pageController.nextPage(
            curve: Curves.easeIn, duration: const Duration(milliseconds: 500));
      }
    }

    ///
    checkProgress();

    ///
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
    debugPrint(totalProgress.toString());
    if (totalProgress == 1) {
      ///
      SoundsManagerController().playAllAzkarFinishedSound();
    }
    update();
  }
}
