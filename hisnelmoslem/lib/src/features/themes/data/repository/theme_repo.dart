import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_platform.dart';

class ThemeRepo {
  final GetStorage box;
  ThemeRepo(this.box);

  ///
  static const String _brightnessKey = "ThemeBrightness";

  Brightness getBrightness() {
    final String? brightness = box.read(_brightnessKey) as String?;
    return brightness == Brightness.light.toString()
        ? Brightness.light
        : Brightness.dark;
  }

  Future setBrightness(Brightness brightness) async {
    await box.write(_brightnessKey, brightness.toString());
  }

  ///
  static const String _themeUseMaterial3Key = "themeUseMaterial3";

  bool getUseMaterial3() {
    final bool? useMaterial3 = box.read(_themeUseMaterial3Key) as bool?;
    return useMaterial3 ?? true;
  }

  Future setUseMaterial3(bool useMaterial3) async {
    await box.write(_themeUseMaterial3Key, useMaterial3);
  }

  ///
  static const String _useOldThemeKey = "themeUseOldTheme";

  bool getUseOldTheme() {
    final bool? useOldTheme = box.read(_useOldThemeKey) as bool?;
    return useOldTheme ?? false;
  }

  Future setUseOldTheme(bool useOldTheme) async {
    await box.write(_useOldThemeKey, useOldTheme);
  }

  ///
  static const String _themeColorKey = "ThemeColor";

  Color getColor() {
    final int? colorValue = box.read(_themeColorKey) as int?;
    return colorValue != null
        ? Color(colorValue)
        : const Color.fromARGB(255, 105, 187, 253);
  }

  Future setColor(Color color) async {
    await box.write(_themeColorKey, color.toARGB32());
  }

  ///
  static const String _backgroundColorKey = "BackgroundColor";

  Color getBackgroundColor() {
    final int? colorValue = box.read(_backgroundColorKey) as int?;
    return colorValue != null ? Color(colorValue) : Colors.black;
  }

  Future setBackgroundColor(Color color) async {
    await box.write(_backgroundColorKey, color.toARGB32());
  }

  ///
  static const String _overrideBackgroundColorKey = "overrideBackgroundColor";

  bool getOverrideBackgroundColor() {
    final bool? useOldTheme = box.read(_overrideBackgroundColorKey) as bool?;
    return useOldTheme ?? false;
  }

  Future setOverrideBackgroundColor(bool useOldTheme) async {
    await box.write(_overrideBackgroundColorKey, useOldTheme);
  }

  ///
  static const _fontFamilyKey = 'font_family';
  String get fontFamily => box.read(_fontFamilyKey) ?? "Roboto";

  Future<void> changFontFamily(String value) async {
    box.write(_fontFamilyKey, value);
  }

  ///

  static const _appLocaleKey = 'app_locale';
  Locale? get appLocale {
    final value = box.read<String?>(_appLocaleKey);
    final Locale? locale;
    if (value == null) {
      final languageCode = PlatformExtension.languageCode;
      if (languageCode == null) {
        locale = null;
      } else {
        ///TODO use languageCode
        // locale = Locale(languageCode);
        locale = const Locale("ar");
      }
    } else {
      locale = Locale(value);
    }

    return locale;
  }

  Future<void> changAppLocale(String value) async {
    box.write(_appLocaleKey, value);
  }
}
