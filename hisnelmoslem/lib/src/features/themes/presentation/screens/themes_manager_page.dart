import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/features/themes/presentation/controller/cubit/theme_cubit.dart';

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
              if (!state.useMaterial3)
                SwitchListTile(
                  value: state.useOldTheme,
                  title: Text("themeUserOldTheme".tr),
                  onChanged: state.useMaterial3
                      ? null
                      : (value) {
                          context.read<ThemeCubit>().changeUseOldTheme(value);
                        },
                ),
              SwitchListTile(
                value: state.overrideBackgroundColor,
                title: Text("themeOverrideBackground".tr),
                onChanged: !state.useMaterial3
                    ? null
                    : (value) {
                        context
                            .read<ThemeCubit>()
                            .changeOverrideBackgroundColor(value);
                      },
              ),
              if (state.overrideBackgroundColor)
                ListTile(
                  title: Text("themeBackgroundColor".tr),
                  trailing: CircleAvatar(
                    backgroundColor: state.backgroundColor,
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        Color selectedColor = state.backgroundColor;
                        return AlertDialog(
                          title: Text("themeBackgroundColor".tr),
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
                              child: Text("Select".tr),
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
