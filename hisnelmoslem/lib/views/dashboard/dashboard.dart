import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/controllers/dashboard_controller.dart';
import 'package:hisnelmoslem/controllers/rearrange_dashboard_page_controller.dart';
import 'package:hisnelmoslem/shared/constants/app_dashboard.dart';
import 'package:hisnelmoslem/shared/widgets/loading.dart';
import 'package:hisnelmoslem/shared/constants/constant.dart';
import 'package:hisnelmoslem/shared/widgets/scroll_glow_custom.dart';
import 'package:hisnelmoslem/shared/widgets/scroll_glow_remover.dart';
import 'package:hisnelmoslem/utils/awesome_notification_manager.dart';
import 'package:hisnelmoslem/views/dashboard/screen_appbar.dart';
import 'package:hisnelmoslem/views/dashboard/screen_menu.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

class AzkarDashboard extends StatelessWidget {
  const AzkarDashboard({
    Key? key,
  }) : super(key: key);

  @override
  build(BuildContext context) {
    return GetBuilder<DashboardController>(
      init: DashboardController(),
      builder: (controller) => controller.isLoading
          ? const Loading()
          : ZoomDrawer(
              isRtl: true,
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
              slideWidth: 250,
            ),
    );
  }
}

class MainScreen extends StatelessWidget {
  final DashboardController controller;
  const MainScreen({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: appDashboardItem.length,
      child: Scaffold(
        body: ScrollGlowRemover(
          child: NestedScrollView(
            floatHeaderSlivers: true,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                ScreenAppBar(controller: controller),
              ];
            },
            body: ScrollGlowCustom(
              axisDirection: AxisDirection.right,
              child: GetBuilder<RearrangeDashboardPageController>(
                  init: RearrangeDashboardPageController(),
                  builder: (rearrangeController) {
                    return TabBarView(
                      // controller: tabController,
                      children: [
                        ...List.generate(
                          appDashboardItem.length,
                          (index) {
                            return appDashboardItem[
                                    rearrangeController.list[index]]
                                .widget;
                          },
                        ),
                      ],
                    );
                  }),
            ),
          ),
        ),
      ),
    );
  }
}
