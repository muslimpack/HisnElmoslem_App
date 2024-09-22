import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/features/themes/presentation/controller/cubit/theme_cubit.dart';

class ThemeManagerScreen extends StatelessWidget {
  const ThemeManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              S.of(context).themeManager,
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              ListTile(
                title: Text(S.of(context).themeAppColor),
                trailing: CircleAvatar(
                  backgroundColor: state.color,
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      Color selectedColor = state.color;
                      return AlertDialog(
                        clipBehavior: Clip.hardEdge,
                        contentPadding: EdgeInsets.zero,
                        content: SingleChildScrollView(
                          child: ColorPicker(
                            hexInputBar: true,
                            enableAlpha: false,
                            pickerColor: state.color,
                            labelTypes: const [],
                            onColorChanged: (value) {
                              selectedColor = value;
                            },
                          ),
                        ),
                        actions: <Widget>[
                          ElevatedButton(
                            child: Text(S.of(context).select),
                            onPressed: () {
                              context
                                  .read<ThemeCubit>()
                                  .changeColor(selectedColor);
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              SwitchListTile(
                value: state.brightness == Brightness.dark,
                title: Text(S.of(context).themeDarkMode),
                onChanged: (value) {
                  if (state.brightness == Brightness.dark) {
                    context
                        .read<ThemeCubit>()
                        .changeBrightness(Brightness.light);
                  } else {
                    context
                        .read<ThemeCubit>()
                        .changeBrightness(Brightness.dark);
                  }
                },
              ),
              SwitchListTile(
                value: state.useMaterial3,
                title: Text(S.of(context).themeUseMaterial3),
                onChanged: (value) {
                  sl<ThemeCubit>().changeUseMaterial3(value);
                },
              ),
              if (!state.useMaterial3)
                SwitchListTile(
                  value: state.useOldTheme,
                  title: Text(S.of(context).themeUserOldTheme),
                  onChanged: state.useMaterial3
                      ? null
                      : (value) {
                          sl<ThemeCubit>().changeUseOldTheme(value);
                        },
                ),
              SwitchListTile(
                value: state.overrideBackgroundColor,
                title: Text(S.of(context).themeOverrideBackground),
                onChanged: !state.useMaterial3
                    ? null
                    : (value) {
                        sl<ThemeCubit>().changeOverrideBackgroundColor(value);
                      },
              ),
              if (state.overrideBackgroundColor)
                ListTile(
                  title: Text(S.of(context).themeBackgroundColor),
                  trailing: CircleAvatar(
                    backgroundColor: state.backgroundColor,
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        Color selectedColor = state.backgroundColor;
                        return AlertDialog(
                          title: Text(S.of(context).themeBackgroundColor),
                          content: SingleChildScrollView(
                            child: ColorPicker(
                              hexInputBar: true,
                              enableAlpha: false,
                              pickerColor: selectedColor,
                              onColorChanged: (value) {
                                selectedColor = value;
                              },
                            ),
                          ),
                          actions: <Widget>[
                            ElevatedButton(
                              child: Text(S.of(context).select),
                              onPressed: () {
                                context
                                    .read<ThemeCubit>()
                                    .changeBackgroundColor(selectedColor);
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
