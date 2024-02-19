import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/themes/theme_services.dart';
import 'package:hisnelmoslem/src/core/themes/themes_enum.dart';

class ThemesManagerPageController extends GetxController {
  /* *************** Variables *************** */
  //
  late AppThemeMode? appThemeModeEnum;

  ///
  double? imageHeight = 200;

  /* *************** Controller life cycle *************** */
  //
  @override
  void onInit() {
    super.onInit();
    appThemeModeEnum = ThemeServices.appThemeMode;
  }

  /* *************** Functions *************** */

  ///
  void handleThemeChange(AppThemeMode? value) {
    appThemeModeEnum = value;
    ThemeServices.handleThemeChange(value);
    Get.forceAppUpdate();
    update();
  }
}
