import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeServices {
  static final _getStorage = GetStorage();
  static const storeKey = "isDarkMode";

  static ThemeMode getTheme() {
    return isDarkMode() ? ThemeMode.dark : ThemeMode.light;
  }

  static bool isDarkMode() {
    return _getStorage.read(storeKey) ?? true;
  }

  static void saveThemeMode(bool isDarkMode) {
    _getStorage.write(storeKey, isDarkMode);
  }

  static void changeThemeMode() {
    Get.changeThemeMode(isDarkMode() ? ThemeMode.light : ThemeMode.dark);
    saveThemeMode(!isDarkMode());
  }
}
