import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hisnelmoslem/src/core/repos/zikr_text_repo.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/themes/data/repository/theme_repo.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final ThemeRepo themeRepo;
  final ZikrTextRepo zikrTextRepo;
  ThemeCubit(this.themeRepo, this.zikrTextRepo)
      : super(
          ThemeState(
            brightness: themeRepo.getBrightness(),
            color: themeRepo.getColor(),
            useMaterial3: themeRepo.getUseMaterial3(),
            useOldTheme: themeRepo.getUseOldTheme(),
            fontFamily: themeRepo.fontFamily,
            backgroundColor: themeRepo.getBackgroundColor(),
            overrideBackgroundColor: themeRepo.getOverrideBackgroundColor(),
            locale: themeRepo.appLocale,
            fontSize: zikrTextRepo.fontSize,
            showDiacritics: zikrTextRepo.showDiacritics,
          ),
        );

  ///MARK: Theme
  Future<void> changeBrightness(Brightness brightness) async {
    await themeRepo.setBrightness(brightness);
    emit(state.copyWith(brightness: brightness));
  }

  Future<void> toggleBrightness() async {
    changeBrightness(
      state.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
    );
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

  Future<void> changeOverrideBackgroundColor(
    bool overrideBackgroundColor,
  ) async {
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
    emit(state.copyWith(locale: Locale(locale)));
  }

  ///MARK: Zikr Text

  Future<void> changFontSize(double value) async {
    final double tempValue = value.clamp(kFontMin, kFontMax);
    await zikrTextRepo.changFontSize(tempValue);
    emit(state.copyWith(fontSize: tempValue));
  }

  Future resetFontSize() async {
    await changFontSize(kFontDefault);
  }

  Future increaseFontSize() async {
    await changFontSize(state.fontSize + kFontChangeBy);
  }

  Future decreaseFontSize() async {
    await changFontSize(state.fontSize - kFontChangeBy);
  }

  /* ******* Diacritics ******* */

  Future<void> changDiacriticsStatus({required bool value}) async {
    await zikrTextRepo.changDiacriticsStatus(value: value);
    emit(state.copyWith(showDiacritics: value));
  }

  Future<void> toggleDiacriticsStatus() async {
    await changDiacriticsStatus(value: !state.showDiacritics);
  }
}
