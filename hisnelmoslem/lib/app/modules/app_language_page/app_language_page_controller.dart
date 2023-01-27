import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/app/data/app_data.dart';
import "package:hisnelmoslem/app/data/models/models.dart";
import 'package:intl/intl.dart';

class AppLanguagePageController extends GetxController {
  /* *************** Variables *************** */
  final box = GetStorage();

  List<int> list = <int>[].obs;

  List<TranslationData> languages = [
    TranslationData(display: "العربية", code: "ar"),
    TranslationData(display: "English", code: "en"),
  ];

  late final ColorScheme colorScheme = Theme.of(Get.context!).colorScheme;
  late final Color activeColor = colorScheme.primary.withOpacity(0.05);

  /* *************** Functions *************** */

  /// get Tally Transition Vibrate mode
  String get activeFont => appData.fontFamily;

  /// set Tally  Transition Vibrate mode
  void changeAppLanguage(String value) {
    Get.updateLocale(Locale(value));
    appData.changAppLocale(value);
    Intl.defaultLocale = value;
    update();
  }
}
