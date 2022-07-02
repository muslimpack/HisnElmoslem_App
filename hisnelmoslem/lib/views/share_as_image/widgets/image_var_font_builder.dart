import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/controllers/dashboard_controller.dart';
import 'package:hisnelmoslem/controllers/share_as_image_controller.dart';
import 'package:hisnelmoslem/models/zikr_content.dart';

class ImageVarFontBuilder extends StatelessWidget {
  final DbContent dbContent;
  const ImageVarFontBuilder({
    Key? key,
    required this.dbContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DashboardController dashboardController = Get.put(DashboardController());
    String titleWithIndex =
        "${dashboardController.allTitle[dbContent.titleId - 1].name} | ذكر رقم ${dbContent.orderId}";
    String titleWithoutIndex =
        dashboardController.allTitle[dbContent.titleId - 1].name;
    return GetBuilder<ShareAsImageController>(builder: (controller) {
      return Card(
        clipBehavior: Clip.hardEdge,
        margin: EdgeInsets.zero,
        color: controller.backgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(30),
          ),
        ),
        child: SizedBox(
          width: controller.imageWidth.toDouble(),
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
                    fontSize: controller.fontSize * controller.titleFactor,
                  ),
                ),
              ),
              Divider(
                color: controller.titleTextColor,
                thickness: controller.dividerSize,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  dbContent.content,
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: controller.bodyTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: controller.fontSize,
                  ),
                ),
              ),
              // Fadl
              Visibility(
                visible: !(dbContent.fadl == "") && controller.showFadl,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    dbContent.fadl,
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: controller.additionalTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: controller.fontSize * controller.fadlFactor,
                    ),
                  ),
                ),
              ),
              // Source
              Visibility(
                visible: !(dbContent.source == "") && controller.showSource,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    dbContent.source,
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: controller.additionalTextColor,
                      fontSize: controller.fontSize * controller.sourceFactor,
                    ),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 40 * controller.titleFactor * 1.5,
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
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
