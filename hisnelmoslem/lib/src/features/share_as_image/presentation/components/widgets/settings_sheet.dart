import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/repository/share_as_image_data.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/components/widgets/color_swatch_builder.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/controller/share_as_image_controller.dart';

class ShareAsImageSettings extends StatelessWidget {
  final ShareAsImageController shareAsImageController;

  const ShareAsImageSettings({
    super.key,
    required this.shareAsImageController,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ShareAsImageController>(
      builder: (context) {
        return Scaffold(
          body: ListView(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            children: [
              ColorSwatchBuilder(
                title: "title color".tr,
                apply: (color) {
                  shareAsImageController.updateTitleColor(color);
                },
                colorSwatchList: shareAsImageController.titleColorsList,
                colorToTrack: shareAsImageData.titleTextColor,
              ),
              ColorSwatchBuilder(
                title: "text color".tr,
                apply: (color) {
                  shareAsImageController.updateTextColor(color);
                },
                colorSwatchList: shareAsImageController.bodyColorsList,
                colorToTrack: shareAsImageData.bodyTextColor,
              ),
              ColorSwatchBuilder(
                title: "subtitle color".tr,
                apply: (color) {
                  shareAsImageController.updateAdditionalTextColor(color);
                },
                colorSwatchList:
                    shareAsImageController.additionalTextColorsList,
                colorToTrack: shareAsImageData.additionalTextColor,
              ),
              ColorSwatchBuilder(
                title: "background color".tr,
                apply: (color) {
                  shareAsImageController.updateBackgroundColor(color);
                },
                colorSwatchList: shareAsImageController.backgroundColors,
                colorToTrack: shareAsImageData.backgroundColor,
              ),
              const Divider(),
              CheckboxListTile(
                title: Text("show zikr index".tr),
                value: shareAsImageData.showZikrIndex,
                onChanged: (value) {
                  shareAsImageController.toggleShowZikrIndex(
                    value: value!,
                  );
                },
              ),
              CheckboxListTile(
                title: Text("show fadl".tr),
                value: shareAsImageData.showFadl,
                onChanged: (value) {
                  shareAsImageController.toggleShowFadl(value: value!);
                },
              ),
              CheckboxListTile(
                title: Text("show source of zikr".tr),
                value: shareAsImageData.showSource,
                onChanged: (value) {
                  shareAsImageController.toggleShowSource(value: value!);
                },
              ),
              const Divider(),
              Text(
                "image quality".tr,
              ),
              SizedBox(
                height: 50,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: List.generate(
                    shareAsImageController.imageQualityList.length,
                    (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        child: ChoiceChip(
                          selected:
                              shareAsImageController.imageQualityList[index] ==
                                  shareAsImageData.imageQuality,
                          onSelected: (val) {
                            shareAsImageController.updateImageQuality(
                              shareAsImageController.imageQualityList[index],
                            );
                          },
                          label: Text(
                            shareAsImageController.imageQualityList[index]
                                .toString(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
