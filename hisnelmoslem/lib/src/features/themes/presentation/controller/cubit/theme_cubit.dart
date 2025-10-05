import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hisnelmoslem/src/features/themes/data/models/theme_brightness_mode_enum.dart';
import 'package:hisnelmoslem/src/features/themes/data/repository/theme_repo.dart';
import 'package:hisnelmoslem/src/features/themes/presentation/components/app_back_button.dart';
import 'package:intl/intl.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final ThemeRepo themeRepo;
  ThemeCubit(this.themeRepo)
    : super(
        ThemeState(
          deviceBrightness: Brightness.dark,
          color: themeRepo.getColor(),
          useMaterial3: themeRepo.getUseMaterial3(),
          useOldTheme: themeRepo.getUseOldTheme(),
          fontFamily: themeRepo.fontFamily,
          backgroundColor: themeRepo.getBackgroundColor(),
          overrideBackgroundColor: themeRepo.getOverrideBackgroundColor(),
          locale: themeRepo.appLocale,
          themeBrightnessMode: themeRepo.getThemeBrightnessMode(),
        ),
      );

  Future start() async {}

  ///MARK: Theme
  Future<void> changeDeviceBrightness(Brightness brightness) async {
    emit(state.copyWith(deviceBrightness: brightness));
  }

  Future<void> changeBrightnessMode(ThemeBrightnessModeEnum brightnessMode) async {
    await themeRepo.setThemeBrightnessMode(brightnessMode);
    emit(state.copyWith(themeBrightnessMode: brightnessMode));
  }

  Future<void> toggleBrightnessMode() async {
    changeBrightnessMode(state.themeBrightnessMode.toggle());
  }

  Future<void> changeUseMaterial3(bool useMaterial3) async {
    await themeRepo.setUseMaterial3(useMaterial3);
    emit(state.copyWith(useMaterial3: useMaterial3));
  }

  Future<void> changeUseOldTheme(bool useOldTheme) async {
    await themeRepo.setUseOldTheme(useOldTheme);
    emit(state.copyWith(useOldTheme: useOldTheme));
  }

  Future<void> changeColor(Color color) async {
    await themeRepo.setColor(color);
    emit(state.copyWith(color: color));
  }

  Future<void> changeBackgroundColor(Color color) async {
    await themeRepo.setBackgroundColor(color);
    emit(state.copyWith(backgroundColor: color));
  }

  Future<void> changeOverrideBackgroundColor(bool overrideBackgroundColor) async {
    await themeRepo.setOverrideBackgroundColor(overrideBackgroundColor);
    emit(state.copyWith(overrideBackgroundColor: overrideBackgroundColor));
  }

  ///MARK:Font Family
  Future<void> changeFontFamily(String fontFamily) async {
    await themeRepo.changFontFamily(fontFamily);
    emit(state.copyWith(fontFamily: fontFamily));
  }

  ///MARK: App Locale
  Future<void> changeAppLocale(String locale) async {
    await themeRepo.changAppLocale(locale);
    Intl.defaultLocale = Locale(locale).languageCode;
    emit(state.copyWith(locale: Locale(locale)));
  }
}
