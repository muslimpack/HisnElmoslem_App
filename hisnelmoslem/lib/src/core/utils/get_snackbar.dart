import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/generated/l10n.dart';

void getSnackbar({String? title, required String message}) {
  Get.snackbar(
    title ?? S.current.message,
    message,
    duration: const Duration(seconds: 1),
    icon: Image.asset("assets/images/app_icon.png"),
  );
}
