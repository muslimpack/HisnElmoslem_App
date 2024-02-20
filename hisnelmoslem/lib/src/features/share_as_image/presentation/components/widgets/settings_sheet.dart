import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/repository/share_as_image_data.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/components/widgets/color_swatch_builder.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/controller/share_as_image_controller.dart';

class SettingsSheet extends StatelessWidget {
  final ShareAsImageController shareAsImageController;

  const SettingsSheet({
    super.key,
    required this.shareAsImageController,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: shareAsImageController.draggableScrollableController,
      initialChildSize: .15,
      minChildSize: .15,
      // maxChildSize: .6,
      builder: (context, scrollController) {
        return Card(
          margin: EdgeInsets.zero,
          elevation: 20,
          clipBehavior: Clip.hardEdge,
          // color: Theme.of(context).bottomAppBarColor.withOpacity(1),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20.0),
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Get.theme.scaffoldBackgroundColor.withOpacity(0.5),
              ),
              padding: const EdgeInsets.all(10),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                controller: scrollController,
                children: [
                  const SizedBox(
                    height: 50,
                    child: Divider(
                      thickness: 7,
                      indent: 20,
                      endIndent: 20,
                    ),
                  ),
                  const Divider(),
                  SizedBox(
                    height: 70,
                    child: ListView(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      children: [
                        Column(
                          children: [
                            Text(
                              "title color".tr,
                            ),
                            ColorSwatchBuilder(
                              apply: (color) {
                                shareAsImageController.updateTitleColor(color);
                              },
                              colorSwatchList:
                                  shareAsImageController.titleColorsList,
                              colorToTrack: shareAsImageData.titleTextColor,
                            ),
                          ],
                        ),
                        const VerticalDivider(),
                        Column(
                          children: [
                            Text(
                              "text color".tr,
                            ),
                            ColorSwatchBuilder(
                              apply: (color) {
                                shareAsImageController.updateTextColor(color);
                              },
                              colorSwatchList:
                                  shareAsImageController.bodyColorsList,
                              colorToTrack: shareAsImageData.bodyTextColor,
                            ),
                          ],
                        ),
                        const VerticalDivider(),
                        Column(
                          children: [
                            Text(
                              "subtitle color".tr,
                            ),
                            ColorSwatchBuilder(
                              apply: (color) {
                                shareAsImageController
                                    .updateAdditionalTextColor(color);
                              },
                              colorSwatchList: shareAsImageController
                                  .additionalTextColorsList,
                              colorToTrack:
                                  shareAsImageData.additionalTextColor,
                            ),
                          ],
                        ),
                        const VerticalDivider(),
                        Column(
                          children: [
                            Text(
                              "background color".tr,
                            ),
                            ColorSwatchBuilder(
                              apply: (color) {
                                shareAsImageController
                                    .updateBackgroundColor(color);
                              },
                              colorSwatchList:
                                  shareAsImageController.backgroundColors,
                              colorToTrack: shareAsImageData.backgroundColor,
                            ),
                          ],
                        ),
                      ],
                    ),
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
                              selected: shareAsImageController
                                      .imageQualityList[index] ==
                                  shareAsImageData.imageQuality,
                              onSelected: (val) {
                                shareAsImageController.updateImageQuality(
                                  shareAsImageController
                                      .imageQualityList[index],
                                );
                              },
                              label: Text(
                                shareAsImageController.imageQualityList[index]
                                    .toString(),
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
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
                  const SizedBox(
                    height: 40,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
