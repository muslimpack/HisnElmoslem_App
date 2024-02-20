import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class ThemeRepo {
  static final _box = GetStorage();

  ///* ******* Themes ******* */
  static const String brightnessKey = "ThemeBrightness";

  static Brightness getBrightness() {
    final String? brightness = _box.read(brightnessKey) as String?;
    return brightness == Brightness.light.toString()
        ? Brightness.light
        : Brightness.dark;
  }

  static Future setBrightness(Brightness brightness) async {
    await _box.write(brightnessKey, brightness.toString());
  }

  static const String themeUseMaterial3Key = "themeUseMaterial3";

  static bool getUseMaterial3() {
    final bool? useMaterial3 = _box.read(themeUseMaterial3Key) as bool?;
    return useMaterial3 ?? true;
  }

  static Future setUseMaterial3(bool useMaterial3) async {
    await _box.write(themeUseMaterial3Key, useMaterial3);
  }

  static const String useOldThemeKey = "themeUseOldTheme";

  static bool getUseOldTheme() {
    final bool? useOldTheme = _box.read(useOldThemeKey) as bool?;
    return useOldTheme ?? false;
  }

  static Future setUseOldTheme(bool useOldTheme) async {
    await _box.write(useOldThemeKey, useOldTheme);
  }

  static const String themeColorKey = "ThemeColor";

  static Color getColor() {
    final int? colorValue = _box.read(themeColorKey) as int?;
    return colorValue != null
        ? Color(colorValue)
        : const Color.fromARGB(255, 105, 187, 253);
  }

  static Future setColor(Color color) async {
    await _box.write(themeColorKey, color.value);
  }

  static const String backgroundColorKey = "BackgroundColor";

  static Color getBackgroundColor() {
    final int? colorValue = _box.read(backgroundColorKey) as int?;
    return colorValue != null ? Color(colorValue) : Colors.black;
  }

  static Future setBackgroundColor(Color color) async {
    await _box.write(backgroundColorKey, color.value);
  }

  static const String overrideBackgroundColorKey = "overrideBackgroundColor";

  static bool getOverrideBackgroundColor() {
    final bool? useOldTheme = _box.read(overrideBackgroundColorKey) as bool?;
    return useOldTheme ?? false;
  }

  static Future setOverrideBackgroundColor(bool useOldTheme) async {
    await _box.write(overrideBackgroundColorKey, useOldTheme);
  }
}
