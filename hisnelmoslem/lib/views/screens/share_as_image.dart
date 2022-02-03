import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/controllers/dashboard_controller.dart';
import 'package:hisnelmoslem/controllers/share_as_image_controller.dart';
import 'package:hisnelmoslem/models/zikr_content.dart';
import 'package:screenshot/screenshot.dart';

class ShareAsImage extends StatelessWidget {
  final DbContent dbContent;
  ShareAsImage({Key? key, required this.dbContent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ShareAsImageController>(
        init: ShareAsImageController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              title: Text(
                "مشاركة كصورة",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "Uthmanic",
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  onPressed: () async {
                    controller.invertColor();
                  },
                  icon: Icon(
                    controller.bInvert
                        ? Icons.invert_colors_off_rounded
                        : Icons.invert_colors_on_rounded,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    controller.shareImage();
                  },
                  icon: Icon(Icons.share),
                ),
              ],
            ),
            body: GestureDetector(
              onDoubleTap: () {
                controller.transformationController.value = Matrix4.identity();
              },
              child: InteractiveViewer(
                  transformationController: controller.transformationController,
                  minScale: 0.25,
                  maxScale: 3,
                  clipBehavior: Clip.antiAlias,
                  boundaryMargin: EdgeInsets.all(500),
                  panEnabled: true,
                  child: Screenshot(
                    controller: controller.screenshotController,
                    child: ImageBuilder(dbContent: dbContent),
                  )),
            ),
          );
        });
  }
}

class ImageBuilder extends StatelessWidget {
  final DbContent dbContent;
  ImageBuilder({
    Key? key,
    required this.dbContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DashboardController dashboardController = Get.put(DashboardController());
    return GetBuilder<ShareAsImageController>(builder: (controller) {
      return Center(
        child: Card(
          margin: EdgeInsets.zero,
          color: controller.backgroundColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                child: Text(
                  "${dashboardController.allTitle[dbContent.titleId - 1].name} - ذكر رقم ${dbContent.orderId}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: "Uthmanic",
                      color: controller.titleColor,
                      fontSize: 20),
                ),
              ),
              Divider(
                color: controller.dividerColor,
                height: 2,
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: Container(
                  child: SizedBox(
                    height: 240,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Center(
                        child: AutoSizeText(
                          dbContent.content,
                          softWrap: true,
                          textAlign: TextAlign.center,
                          minFontSize: 10,
                          style: TextStyle(
                              color: controller.textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Fadl
              Visibility(
                visible: !(dbContent.fadl == ""),
                child: Container(
                  height: 100,
                  padding: EdgeInsets.all(10),
                  child: Container(
                    child: SizedBox(
                      height: 240,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Center(
                          child: AutoSizeText(
                            dbContent.fadl,
                            softWrap: true,
                            textAlign: TextAlign.center,
                            minFontSize: 10,
                            style: TextStyle(
                                color: controller.textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Divider(
                color: controller.dividerColor,
                height: 2,
              ),
              //Bottom
              Container(
                padding: EdgeInsets.all(10),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SizedBox(
                      width: 40,
                      child: Image.asset("assets/images/app_icon.png")),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    height: 30,
                    width: 1.5,
                    color: controller.appNameColor,
                  ),
                  Text(
                    "تطبيق حصن المسلم",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "Uthmanic",
                        color: controller.appNameColor,
                        fontSize: 17),
                  )
                ]),
              ),
            ],
          ),
        ),
      );
    });
  }
}
