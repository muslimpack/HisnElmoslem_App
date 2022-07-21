import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/app/views/dashboard/dashboard_controller.dart';
import 'package:hisnelmoslem/app/modules/share_as_image/share_as_image_controller.dart';
import 'package:hisnelmoslem/app/data/models/zikr_content.dart';

class ImageBuilder extends StatelessWidget {
  final DbContent dbContent;

  const ImageBuilder({
    Key? key,
    required this.dbContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DashboardController dashboardController = Get.put(DashboardController());
    return GetBuilder<ShareAsImageController>(builder: (controller) {
      String titleWithIndex =
          "${dashboardController.allTitle[dbContent.titleId - 1].name} | ذكر رقم ${dbContent.orderId}";
      String titleWithoutIndex =
          dashboardController.allTitle[dbContent.titleId - 1].name;
      return Center(
        child: SizedBox(
          width: controller.imageWidth.toDouble(),
          child: Card(
            margin: EdgeInsets.zero,
            color: controller.backgroundColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    controller.showZikrIndex
                        ? titleWithIndex
                        : titleWithoutIndex,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "Uthmanic",
                        color: controller.titleTextColor,
                        fontSize: 20),
                  ),
                ),
                Divider(
                  color: controller.titleTextColor,
                  thickness: controller.dividerSize,
                ),
                Container(
                  constraints:
                      const BoxConstraints(minHeight: 100, maxHeight: 350),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: AutoSizeText(
                      dbContent.content,
                      softWrap: true,
                      textAlign: TextAlign.center,
                      minFontSize: 12,
                      style: TextStyle(
                          color: controller.bodyTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                ),
                // Fadl
                Visibility(
                  visible: !(dbContent.fadl == "") && controller.showFadl,
                  child: Container(
                    constraints:
                        const BoxConstraints(minHeight: 50, maxHeight: 200),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: AutoSizeText(
                            dbContent.fadl,
                            softWrap: true,
                            textAlign: TextAlign.center,
                            minFontSize: 10,
                            style: TextStyle(
                                color: controller.additionalTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Source
                Visibility(
                  visible: !(dbContent.source == "") && controller.showSource,
                  child: Container(
                    constraints:
                        const BoxConstraints(minHeight: 50, maxHeight: 200),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: AutoSizeText(
                            dbContent.source,
                            softWrap: true,
                            textAlign: TextAlign.center,
                            minFontSize: 10,
                            style: TextStyle(
                                color: controller.additionalTextColor,
                                // fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(
                  color: controller.titleTextColor,
                  thickness: controller.dividerSize,
                ),
                //Bottom
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            width: 40,
                            child: Image.asset("assets/images/app_icon.png")),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          height: 30,
                          width: controller.dividerSize,
                          color: controller.titleTextColor,
                        ),
                        Text(
                          "تطبيق حصن المسلم",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: "Uthmanic",
                              color: controller.titleTextColor,
                              fontSize: 20),
                        )
                      ]),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
