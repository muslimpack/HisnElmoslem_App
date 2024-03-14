// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_object.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/font_settings.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/features/home/presentation/controller/dashboard_controller.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/zikr_viewer_card_mode_builder.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/controller/azkar_read_card_controller.dart';

class AzkarReadCard extends StatelessWidget {
  final int index;

  const AzkarReadCard({super.key, required this.index});

  static DashboardController dashboardController =
      Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AzkarReadCardController>(
      init: AzkarReadCardController(index: index),
      builder: (controller) {
        return controller.isLoading!
            ? const Loading()
            : Scaffold(
                key: controller.vReadScaffoldKey,
                appBar: AppBar(
                  centerTitle: true,
                  title: Text(
                    controller.zikrTitle!.name,
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "${controller.zikrContent.length}".toArabicNumber(),
                      ),
                    ),
                  ],
                  bottom: PreferredSize(
                    preferredSize: const Size(100, 5),
                    child: Stack(
                      children: [
                        LinearProgressIndicator(
                          value: controller.totalProgressForEverySingle,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        LinearProgressIndicator(
                          backgroundColor: Colors.transparent,
                          value: controller.totalProgress,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withGreen(100)
                                .withAlpha(100),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                body: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.zikrContent.length.isNaN
                      ? 0
                      : controller.zikrContent.length,
                  itemBuilder: (context, index) {
                    return ZikrViewerCardBuilder(
                      index: index,
                      controller: controller,
                      dashboardController: dashboardController,
                    );
                  },
                ),
                bottomNavigationBar: BottomAppBar(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(
                        child: FontSettingsToolbox(
                          controllerToUpdate: controller,
                        ),
                      ),
                    ],
                  ),
                ),
              );
      },
    );
  }
}
