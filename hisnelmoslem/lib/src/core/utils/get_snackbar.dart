import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

void getSnackbar({String? title, required String message}) {
  Get.snackbar(
    title ?? "message".tr,
    message,
    duration: const Duration(seconds: 1),
    icon: Image.asset("assets/images/app_icon.png"),
  );
}
