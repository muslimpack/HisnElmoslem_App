import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/app/modules/theme_manager/themes_manager_page_controller.dart';
import 'package:hisnelmoslem/app/shared/widgets/scroll_glow_custom.dart';
import 'package:hisnelmoslem/core/themes/themes_enum.dart';

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
            title: Text("theme manager".tr,
                style: const TextStyle(fontFamily: "Uthmanic")),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
          ),
          body: ScrollGlowCustom(
            child: ListView(
              physics: const ClampingScrollPhysics(),
              children: [
                RadioImage(
                  controller: controller,
                  title: "light theme".tr,
                  icon: Icons.light_mode,
                  appThemeModeValue: AppThemeMode.light,
                ),
                RadioImage(
                  controller: controller,
                  title: "optimize light theme".tr,
                  icon: Icons.light_mode,
                  appThemeModeValue: AppThemeMode.yellowTheme,
                ),
                const Divider(),
                RadioImage(
                  controller: controller,
                  title: "dark theme".tr,
                  icon: Icons.dark_mode,
                  appThemeModeValue: AppThemeMode.defaultDark,
                ),
                RadioImage(
                  controller: controller,
                  title: "optimize dark theme".tr,
                  icon: Icons.dark_mode,
                  appThemeModeValue: AppThemeMode.dark,
                ),
                RadioImage(
                  controller: controller,
                  title: "True black theme".tr,
                  icon: Icons.dark_mode,
                  appThemeModeValue: AppThemeMode.trueblack,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class RadioImage extends StatelessWidget {
  final ThemesManagerPageController controller;
  final String title;
  final dynamic appThemeModeValue;
  final IconData icon;

  const RadioImage({
    super.key,
    required this.controller,
    required this.title,
    this.appThemeModeValue,
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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          )),
      value: appThemeModeValue,
      groupValue: controller.appThemeModeEnum,
      onChanged: (AppThemeMode? value) {
        controller.handleThemeChange(value);
      },
    );
  }
}
