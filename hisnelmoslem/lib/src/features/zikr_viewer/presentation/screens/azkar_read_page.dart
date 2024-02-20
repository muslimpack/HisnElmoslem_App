// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/extensions/string_extension.dart';
import 'package:hisnelmoslem/src/core/repos/app_data.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/features/home/presentation/controller/dashboard_controller.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/zikr_viewer_page_mode_appbar.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/zikr_viewer_page_mode_bottom_bar.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/zikr_viewer_page_mode_page_builder.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/controller/azkar_read_page_controller.dart';

class AzkarReadPage extends StatelessWidget {
  final int index;

  const AzkarReadPage({super.key, required this.index});
  static DashboardController dashboardController =
      Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AzkarReadPageController>(
      init: AzkarReadPageController(index: index),
      builder: (controller) {
        String? text = "";
        String? source = "";
        String? fadl = "";
        int? cardNumber = 0;
        if (!controller.isLoading) {
          text = appData.isDiacriticsEnabled
              ? controller.zikrContent[controller.currentPage].content
              : controller
                  .zikrContent[controller.currentPage].content.removeDiacritics;

          source = controller.zikrContent[controller.currentPage].source;
          fadl = controller.zikrContent[controller.currentPage].fadl;
          cardNumber = controller.currentPage + 1;
        }

        return controller.isLoading
            ? const Loading()
            : Scaffold(
                key: controller.hReadScaffoldKey,
                appBar: AppBar(
                  centerTitle: true,
                  title: Text(
                    controller.zikrTitle!.name,
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "${controller.currentPage + 1}::${controller.zikrContent.length}",
                      ),
                    ),
                  ],
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(50),
                    child: ZikrViewerPageModeAppBar(
                      controller: controller,
                      text: text,
                      fadl: fadl,
                    ),
                  ),
                ),
                body: PageView.builder(
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: controller.onPageViewChange,
                  controller: controller.pageController,
                  itemCount: controller.zikrContent.length.isNaN
                      ? 0
                      : controller.zikrContent.length,
                  itemBuilder: (context, index) {
                    return ZikrViewerPageBuilder(
                      index: index,
                      source: source,
                      controller: controller,
                    );
                  },
                ),
                bottomNavigationBar: ZikrViewerPageModeBottomBar(
                  controller: controller,
                  text: text,
                  fadl: fadl,
                  cardNumber: cardNumber,
                ),
              );
      },
    );
  }
}
