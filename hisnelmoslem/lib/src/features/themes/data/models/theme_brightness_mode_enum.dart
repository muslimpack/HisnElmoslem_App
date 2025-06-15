import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';

enum ThemeBrightnessModeEnum { system, light, dark }

extension ThemeBrightnessModeEnumExtension on ThemeBrightnessModeEnum {
  String localeName(BuildContext context) {
    switch (this) {
      case ThemeBrightnessModeEnum.system:
        return S.of(context).brightnessSystem;

      case ThemeBrightnessModeEnum.dark:
        return S.of(context).brightnessDark;

      case ThemeBrightnessModeEnum.light:
        return S.of(context).brightnessLight;
    }
  }
}
