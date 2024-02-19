import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';

import 'package:hisnelmoslem/src/features/themes/data/models/themes.dart';
import 'package:hisnelmoslem/src/features/themes/data/models/themes_enum.dart';

class ThemeServices {
  ///
  static final box = GetStorage();
  static const storeKey = "appThemeMode";

  /// Get appMode from storage
  static AppThemeMode? get appThemeMode {
    String? stringVal = box.read<String>(storeKey);
    if (stringVal == null) {
      stringVal = EnumToString.convertToString(AppThemeMode.defaultDark);
      changeAppThemeModeStatus(
        EnumToString.fromString(AppThemeMode.values, stringVal),
      );
    }
    return EnumToString.fromString(AppThemeMode.values, stringVal);
  }

  /// Save Changes to storage
  static void changeAppThemeModeStatus(AppThemeMode? value) {
    final stringfyVal = EnumToString.convertToString(value);
    box.write(storeKey, stringfyVal);
  }

  /// Get AppTheme and change themes depend on its values
  static void handleThemeChange(AppThemeMode? value) {
    try {
      changeAppThemeModeStatus(value);
      if (value == AppThemeMode.light) {
        Get.changeTheme(Themes.light);
      } else if (value == AppThemeMode.dark) {
        Get.changeTheme(Themes.dark);
      } else if (value == AppThemeMode.defaultDark) {
        Get.changeTheme(Themes.darkDefault);
      } else if (value == AppThemeMode.yellowTheme) {
        Get.changeTheme(Themes.yellowTheme);
      } else if (value == AppThemeMode.trueblack) {
        Get.changeTheme(Themes.trueBlack);
      }
    } catch (e) {
      hisnPrint(e.toString());
    }
  }

  /// Check if current theme is dark
  static bool isDarkMode() {
    if (appThemeMode == AppThemeMode.dark ||
        appThemeMode == AppThemeMode.defaultDark ||
        appThemeMode == AppThemeMode.trueblack) {
      return true;
    } else {
      return false;
    }
  }

  /// toggle all themes
  static void changeThemeMode() {
    if (appThemeMode == AppThemeMode.yellowTheme) {
      handleThemeChange(AppThemeMode.dark);
    } else if (appThemeMode == AppThemeMode.dark) {
      handleThemeChange(AppThemeMode.defaultDark);
    } else if (appThemeMode == AppThemeMode.defaultDark) {
      handleThemeChange(AppThemeMode.trueblack);
    } else if (appThemeMode == AppThemeMode.trueblack) {
      handleThemeChange(AppThemeMode.light);
    } else if (appThemeMode == AppThemeMode.light) {
      handleThemeChange(AppThemeMode.yellowTheme);
    }
  }

  /// Get appMode
  static ThemeData getTheme() {
    if (appThemeMode == AppThemeMode.light) {
      return Themes.light;
    } else if (appThemeMode == AppThemeMode.dark) {
      return Themes.dark;
    } else if (appThemeMode == AppThemeMode.defaultDark) {
      return Themes.darkDefault;
    } else if (appThemeMode == AppThemeMode.yellowTheme) {
      return Themes.yellowTheme;
    } else if (appThemeMode == AppThemeMode.trueblack) {
      return Themes.trueBlack;
    } else {
      return Themes.dark;
    }
  }
}
