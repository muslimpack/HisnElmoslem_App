import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'themes.dart';
import 'themes_enum.dart';

class ThemeServices {
  ///
  static final box = GetStorage();
  static const storeKey = "appThemeMode";

  /// Get appMode from storage
  static AppThemeMode get appThemeMode =>
      box.read<AppThemeMode>(storeKey) ?? AppThemeMode.dark;

  /// Save Changes to storage
  static void changeAppThemeModeStatus(AppThemeMode? val) =>
      box.write(storeKey, val);

  /// Get AppTheme and change themes depend on its values
  static void handleThemeChange(AppThemeMode? val) {
    changeAppThemeModeStatus(val);
    if (val == AppThemeMode.light) {
      Get.changeTheme(Themes.light);
    } else if (val == AppThemeMode.dark) {
      Get.changeTheme(Themes.dark);
    } else if (val == AppThemeMode.defaultDark) {
      Get.changeTheme(Themes.darkDefault);
    }
  }

  /// Check if current theme is dark
  static bool isDarkMode() {
    if (appThemeMode == AppThemeMode.dark ||
        appThemeMode == AppThemeMode.defaultDark) {
      return true;
    } else {
      return false;
    }
  }

  /// toggle all themes
  static changeThemeMode() {
    if (appThemeMode == AppThemeMode.light) {
      handleThemeChange(AppThemeMode.dark);
    } else if (appThemeMode == AppThemeMode.dark) {
      handleThemeChange(AppThemeMode.defaultDark);
    } else if (appThemeMode == AppThemeMode.defaultDark) {
      handleThemeChange(AppThemeMode.light);
    }
  }

  /// Get appMode
  static ThemeData? getTheme() {
    if (appThemeMode == AppThemeMode.light) {
      return Themes.light;
    } else if (appThemeMode == AppThemeMode.dark) {
      return Themes.dark;
    } else if (appThemeMode == AppThemeMode.defaultDark) {
      return Themes.darkDefault;
    }
  }
}
