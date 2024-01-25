import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/dashboard/presentation/components/main_screen.dart';
import 'package:hisnelmoslem/src/features/dashboard/presentation/components/screen_menu.dart';
import 'package:hisnelmoslem/src/features/dashboard/presentation/controller/dashboard_controller.dart';
import 'package:intl/intl.dart';

class AzkarDashboard extends StatelessWidget {
  const AzkarDashboard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      init: DashboardController(),
      builder: (controller) => controller.isLoading
          ? const Loading()
          : Scaffold(
              body: ZoomDrawer(
                isRtl: Bidi.isRtlLanguage(Get.locale?.languageCode),
                controller: controller.zoomDrawerController,
                menuBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
                menuScreen: ScreenMenu(
                  controller: controller,
                ),
                mainScreen: MainScreen(
                  controller: controller,
                ),
                borderRadius: 24.0,
                showShadow: true,
                angle: 0.0,
                drawerShadowsBackgroundColor: mainColor,
                slideWidth: 270,
              ),
            ),
    );
  }
}
