import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/src/core/repos/app_data.dart';

class FontFamilyPageController extends GetxController {
  /* *************** Variables *************** */
  final box = GetStorage();

  List<int> list = <int>[].obs;

  List<String> fontFamilies = [
    "Cairo",
    "Amiri",
    "Marhey",
    "Vazirmatn",
    "ElMessiri",
    "Harmattan",
    "Lateef",
    "Mada",
    "Changa",
    "ArefRuqaa",
    "Tajawal",
    "NotoNastaliqUrdu",
    "Lalezar",
    "Uthmanic",
    "ReemKufi",
    "Rakkas",
  ];

  late final ColorScheme colorScheme = Theme.of(Get.context!).colorScheme;
  late final Color activeColor = colorScheme.primary.withOpacity(0.05);

  /* *************** Functions *************** */

  /// get Tally Transition Vibrate mode
  String get activeFont => appData.fontFamily;

  /// set Tally  Transition Vibrate mode
  void changeFontFamily(String value) {
    appData.changFontFamily(value);
    Get.forceAppUpdate();
    update();
  }
}
