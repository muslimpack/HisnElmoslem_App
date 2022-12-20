import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/app/data/models/zikr_content.dart';
import 'package:hisnelmoslem/app/data/share_as_image_data.dart';
import 'package:hisnelmoslem/app/modules/share_as_image/share_as_image_controller.dart';

class ImageVarFontBuilder extends StatelessWidget {
  final DbContent dbContent;

  const ImageVarFontBuilder({
    super.key,
    required this.dbContent,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ShareAsImageController>(builder: (controller) {
      return Card(
        clipBehavior: Clip.hardEdge,
        margin: EdgeInsets.zero,
        color: shareAsImageData.backgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(30),
          ),
        ),
        child: SizedBox(
          width: shareAsImageData.imageWidth.toDouble(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Text(
                  controller.getImageTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: shareAsImageData.titleTextColor,
                    fontSize:
                        shareAsImageData.fontSize * controller.titleFactor,
                  ),
                ),
              ),
              Divider(
                color: shareAsImageData.titleTextColor,
                thickness: controller.dividerSize,
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        dbContent.content,
                        softWrap: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: shareAsImageData.bodyTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: shareAsImageData.fontSize,
                        ),
                      ),
                    ),
                    // Fadl
                    Visibility(
                      visible:
                          !(dbContent.fadl == "") && shareAsImageData.showFadl,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          dbContent.fadl,
                          softWrap: true,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: shareAsImageData.additionalTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: shareAsImageData.fontSize *
                                controller.fadlFactor,
                          ),
                        ),
                      ),
                    ),
                    // Source
                    Visibility(
                      visible: !(dbContent.source == "") &&
                          shareAsImageData.showSource,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          dbContent.source,
                          softWrap: true,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: shareAsImageData.additionalTextColor,
                            fontSize: shareAsImageData.fontSize *
                                controller.sourceFactor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Divider(
                color: shareAsImageData.titleTextColor,
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
                      color: shareAsImageData.titleTextColor,
                    ),
                    Text(
                      "تطبيق حصن المسلم",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: shareAsImageData.titleTextColor,
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
