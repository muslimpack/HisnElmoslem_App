import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/features/dashboard/data/models/app_dashboard.dart';
import 'package:hisnelmoslem/src/features/dashboard/presentation/components/screen_appbar.dart';
import 'package:hisnelmoslem/src/features/dashboard/presentation/controller/dashboard_controller.dart';
import 'package:hisnelmoslem/src/features/settings/presentation/components/rearrange_dashboard/rearrange_dashboard_page_controller.dart';

class MainScreen extends StatelessWidget {
  final DashboardController controller;

  const MainScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        physics: const BouncingScrollPhysics(),
        floatHeaderSlivers: true,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            ScreenAppBar(controller: controller),
          ];
        },
        body: GetBuilder<RearrangeDashboardPageController>(
          init: RearrangeDashboardPageController(),
          builder: (rearrangeController) {
            return TabBarView(
              physics: const BouncingScrollPhysics(),
              controller: controller.tabController,
              children: [
                ...List.generate(
                  appDashboardItem.length,
                  (index) {
                    return appDashboardItem[rearrangeController.list[index]]
                        .widget;
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
