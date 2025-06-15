import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/features/themes/data/models/theme_brightness_mode_enum.dart';
import 'package:hisnelmoslem/src/features/themes/presentation/controller/cubit/theme_cubit.dart';

class ToggleBrightnessButton extends StatelessWidget {
  const ToggleBrightnessButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return IconButton(
          tooltip: state.themeBrightnessMode.localeName(context),
          onPressed: () {
            sl<ThemeCubit>().toggleBrightnessMode();
          },
          icon: Icon(switch (state.themeBrightnessMode) {
            ThemeBrightnessModeEnum.dark => Icons.dark_mode,
            ThemeBrightnessModeEnum.light => Icons.light_mode,
            ThemeBrightnessModeEnum.system => Icons.brightness_medium_outlined,
          }),
        );
      },
    );
  }
}
