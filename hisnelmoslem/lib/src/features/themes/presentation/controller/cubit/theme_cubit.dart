import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hisnelmoslem/src/features/themes/data/repository/theme_repo.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit()
      : super(
          ThemeState(
            brightness: ThemeRepo.getBrightness(),
            color: ThemeRepo.getColor(),
            useMaterial3: ThemeRepo.getUseMaterial3(),
            useOldTheme: ThemeRepo.getUseOldTheme(),
          ),
        );

  Future<void> changeBrightness(Brightness brightness) async {
    await ThemeRepo.setBrightness(brightness);
    emit(state.copyWith(brightness: brightness));
  }

  Future<void> changeUseMaterial3(bool useMaterial3) async {
    await ThemeRepo.setUseMaterial3(useMaterial3);
    emit(state.copyWith(useMaterial3: useMaterial3));
  }

  Future<void> changeUseOldTheme(bool useOldTheme) async {
    await ThemeRepo.setUseOldTheme(useOldTheme);
    emit(state.copyWith(useOldTheme: useOldTheme));
  }

  Future<void> changeColor(Color color) async {
    await ThemeRepo.setColor(color);
    emit(state.copyWith(color: color));
  }
}
