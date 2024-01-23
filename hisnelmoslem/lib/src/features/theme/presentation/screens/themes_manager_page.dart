import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/features/theme/data/models/themes_enum.dart';
import 'package:hisnelmoslem/src/features/theme/presentation/controller/themes_manager_page_controller.dart';

class ThemeManagerPage extends StatelessWidget {
  const ThemeManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemesManagerPageController>(
      init: ThemesManagerPageController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              S.of(context).theme_manager,
              style: const TextStyle(fontFamily: "Uthmanic"),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              RadioImage(
                controller: controller,
                title: S.of(context).light_theme,
                icon: Icons.light_mode,
                appThemeModeValue: AppThemeMode.light,
              ),
              RadioImage(
                controller: controller,
                title: S.of(context).optimize_light_theme,
                icon: Icons.light_mode,
                appThemeModeValue: AppThemeMode.yellowTheme,
              ),
              const Divider(),
              RadioImage(
                controller: controller,
                title: S.of(context).dark_theme,
                icon: Icons.dark_mode,
                appThemeModeValue: AppThemeMode.defaultDark,
              ),
              RadioImage(
                controller: controller,
                title: S.of(context).optimize_dark_theme,
                icon: Icons.dark_mode,
                appThemeModeValue: AppThemeMode.dark,
              ),
              RadioImage(
                controller: controller,
                title: S.of(context).true_black_theme,
                icon: Icons.dark_mode,
                appThemeModeValue: AppThemeMode.trueblack,
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
