import 'package:get/get.dart';
import 'package:hisnelmoslem/themes/theme_services.dart';

class SettingsController extends GetxController {
  /* *************** Variables *************** */
  //

  /* *************** Controller life cycle *************** */
  //
  @override
  void onInit() {
    super.onInit();
  }

  //
  @override
  void onClose() {
    super.onClose();
  }

  void toggleTheme() {
    ThemeServices.changeThemeMode();
    update();
  }

  /* *************** Functions *************** */
  //
}
