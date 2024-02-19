import 'package:get/get.dart';
import 'package:hisnelmoslem/src/features/themes/data/models/themes_enum.dart';
import 'package:hisnelmoslem/src/features/themes/data/repository/theme_services.dart';

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
