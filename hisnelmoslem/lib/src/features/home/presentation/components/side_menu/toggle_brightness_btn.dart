import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/src/features/themes/presentation/controller/cubit/theme_cubit.dart';

class ToggleBrightnessButton extends StatelessWidget {
  const ToggleBrightnessButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return IconButton(
          onPressed: () {
            context.read<ThemeCubit>().toggleBrightness();
          },
          icon: Icon(
            state.brightness == Brightness.dark
                ? Icons.dark_mode
                : Icons.light_mode,
            size: 35,
          ),
        );
      },
    );
  }
}
