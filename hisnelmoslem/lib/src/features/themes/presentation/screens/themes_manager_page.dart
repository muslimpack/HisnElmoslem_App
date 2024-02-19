import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/features/themes/data/models/themes_enum.dart';
import 'package:hisnelmoslem/src/features/themes/presentation/controller/cubit/theme_cubit.dart';
import 'package:hisnelmoslem/src/features/themes/presentation/controller/themes_manager_page_controller.dart';

class ThemeManagerPage extends StatelessWidget {
  const ThemeManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              "theme manager".tr,
              style: const TextStyle(fontFamily: "Uthmanic"),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              ListTile(
                title: Text("themeAppColor".tr),
                trailing: CircleAvatar(
                  backgroundColor: state.color,
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      Color selectedColor = state.color;
                      return AlertDialog(
                        title: Text("themeSelectColor".tr),
                        content: SingleChildScrollView(
                          child: ColorPicker(
                            hexInputBar: true,
                            enableAlpha: false,
                            pickerColor: state.color,
                            onColorChanged: (value) {
                              selectedColor = value;
                            },
                          ),
                        ),
                        actions: <Widget>[
                          ElevatedButton(
                            child: Text("Select".tr),
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
                title: Text("themeDarkMode".tr),
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
                title: Text("themeUseMaterial3".tr),
                onChanged: (value) {
                  context.read<ThemeCubit>().changeUseMaterial3(value);
                },
              ),
              SwitchListTile(
                value: state.useOldTheme,
                title: Text("themeUserOldTheme".tr),
                onChanged: state.useMaterial3
                    ? null
                    : (value) {
                        context.read<ThemeCubit>().changeUseOldTheme(value);
                      },
              ),
            ],
          ),
        );
      },
    );
  }
}

class RadioImage extends StatelessWidget {
  final ThemesManagerPageController controller;
  final String title;
  final AppThemeMode appThemeModeValue;
  final IconData icon;

  const RadioImage({
    super.key,
    required this.controller,
    required this.title,
    required this.appThemeModeValue,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<AppThemeMode>(
      title: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          leading: Icon(icon),
          title: Text(
            title,
            style: const TextStyle(),
          ),
        ),
      ),
      value: appThemeModeValue,
      groupValue: controller.appThemeModeEnum,
      onChanged: (AppThemeMode? value) {
        controller.handleThemeChange(value);
      },
    );
  }
}
