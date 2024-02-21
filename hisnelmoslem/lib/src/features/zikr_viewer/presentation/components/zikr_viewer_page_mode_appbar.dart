import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/shared/dialogs/commentary_dialog.dart';
import 'package:hisnelmoslem/src/core/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/src/features/home/presentation/controller/dashboard_controller.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/screens/share_as_image.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/controller/azkar_read_page_controller.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share/share.dart';

class ZikrViewerPageModeAppBar extends StatelessWidget {
  const ZikrViewerPageModeAppBar({
    super.key,
    required this.controller,
    required this.text,
    required this.fadl,
  });

  final AzkarReadPageController controller;
  final String? text;
  final String? fadl;
  @override
  Widget build(BuildContext context) {
    final DashboardController dashboardController =
        Get.put(DashboardController());
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: IconButton(
                    splashRadius: 20,
                    icon: const Icon(MdiIcons.comment),
                    onPressed: () {
                      showCommentaryDialog(
                        context: Get.context!,
                        contentId:
                            controller.zikrContent[controller.currentPage].id,
                      );
                    },
                  ),
                ),
                Expanded(
                  child: IconButton(
                    splashRadius: 20,
                    icon: const Icon(MdiIcons.camera),
                    onPressed: () {
                      transitionAnimation.circleReval(
                        context: Get.context!,
                        goToPage: ShareAsImage(
                          dbContent:
                              controller.zikrContent[controller.currentPage],
                        ),
                      );
                    },
                  ),
                ),
                if (!controller.zikrContent[controller.currentPage].favourite)
                  Expanded(
                    child: IconButton(
                      splashRadius: 20,
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.favorite_border,
                      ),
                      onPressed: () {
                        controller.zikrContent[controller.currentPage]
                            .favourite = true;
                        controller.update();
                        //
                        dashboardController.addContentToFavourite(
                          controller.zikrContent[controller.currentPage],
                        );
                        //
                        // dashboardController.update();
                      },
                    ),
                  )
                else
                  Expanded(
                    child: IconButton(
                      splashRadius: 20,
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.favorite,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {
                        controller.zikrContent[controller.currentPage]
                            .favourite = false;
                        controller.update();

                        dashboardController.removeContentFromFavourite(
                          controller.zikrContent[controller.currentPage],
                        );
                      },
                    ),
                  ),
                Expanded(
                  child: IconButton(
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      Share.share("${text!}\n${fadl!}");
                    },
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      controller.zikrContent[controller.currentPage].count
                          .toString(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Stack(
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
        ],
      ),
    );
  }
}
