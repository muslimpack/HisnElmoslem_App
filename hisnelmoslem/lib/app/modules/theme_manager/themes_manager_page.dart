import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:hisnelmoslem/app/modules/theme_manager/themes_manager_page_controller.dart';
import 'package:hisnelmoslem/app/shared/widgets/scroll_glow_custom.dart';
import 'package:hisnelmoslem/core/themes/themes_enum.dart';

class ThemeManagerPage extends StatelessWidget {
  const ThemeManagerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemesManagerPageController>(
      init: ThemesManagerPageController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text("وضع الألوان داخل التطبيق",
                style: TextStyle(fontFamily: "Uthmanic")),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
          ),
          body: ScrollGlowCustom(
            child: ListView(
              physics: const ClampingScrollPhysics(),
              children: [
                RadioImage(
                  controller: controller,
                  title: "الوضع الفاتح",
                  imgPath: "assets/images/theme_light.png",
                  appThemeModeValue: AppThemeMode.light,
                ),
                RadioImage(
                  controller: controller,
                  title: "الوضع الفاتح المحسن",
                  imgPath: "assets/images/theme_yellow.png",
                  appThemeModeValue: AppThemeMode.yellowTheme,
                ),
                RadioImage(
                  controller: controller,
                  title: "الوضع المعتم",
                  imgPath: "assets/images/theme_dark_default.png",
                  appThemeModeValue: AppThemeMode.defaultDark,
                ),
                RadioImage(
                  controller: controller,
                  title: "الوضع المعتم المحسن",
                  imgPath: "assets/images/theme_dark.png",
                  appThemeModeValue: AppThemeMode.dark,
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
  final String imgPath;
  final dynamic appThemeModeValue;

  const RadioImage({
    Key? key,
    required this.controller,
    required this.title,
    required this.imgPath,
    this.appThemeModeValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RadioListTile<AppThemeMode>(
      title: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      value: appThemeModeValue,
      groupValue: controller.appThemeModeEnum,
      onChanged: (AppThemeMode? value) {
        controller.handleThemeChange(value);
      },
      subtitle: SizedBox(
          height: controller.imageHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Image.asset(
              imgPath,
              fit: BoxFit.cover,
            ),
          )),
    );
  }
}
