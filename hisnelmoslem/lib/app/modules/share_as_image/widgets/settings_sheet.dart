import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/app/modules/share_as_image/share_as_image_controller.dart';
import 'package:hisnelmoslem/core/values/constant.dart';
import 'package:hisnelmoslem/app/shared/widgets/scroll_glow_remover.dart';

import 'color_swatch_builder.dart';

class SettingsSheet extends StatelessWidget {
  final ShareAsImageController shareAsImageController;

  const SettingsSheet({
    Key? key,
    required this.shareAsImageController,
  }) : super(key: key);

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
          color: Theme.of(context).bottomAppBarColor.withOpacity(1),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20.0),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(10),
            child: ScrollGlowRemover(
              child: ListView(
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
                  Text(
                    "title color".tr,
                  ),
                  ColorSwatchBuilder(
                    apply: (color) {
                      shareAsImageController.updateTitleColor(color);
                    },
                    colorSwatchList: shareAsImageController.titleColorsList,
                    colorToTrack: shareAsImageController.titleTextColor,
                  ),
                  const Divider(),
                  Text(
                    "text color".tr,
                  ),
                  ColorSwatchBuilder(
                    apply: (color) {
                      shareAsImageController.updateTextColor(color);
                    },
                    colorSwatchList: shareAsImageController.bodyColorsList,
                    colorToTrack: shareAsImageController.bodyTextColor,
                  ),
                  const Divider(),
                  Text(
                    "subtitle color".tr,
                  ),
                  ColorSwatchBuilder(
                    apply: (color) {
                      shareAsImageController.updateAdditionalTextColor(color);
                    },
                    colorSwatchList:
                        shareAsImageController.additionalTextColorsList,
                    colorToTrack: shareAsImageController.additionalTextColor,
                  ),
                  const Divider(),
                  Text(
                    "background color".tr,
                  ),
                  ColorSwatchBuilder(
                    apply: (color) {
                      shareAsImageController.updateBackgroundColor(color);
                    },
                    colorSwatchList: shareAsImageController.backgroundColors,
                    colorToTrack: shareAsImageController.backgroundColor,
                  ),
                  const Divider(),
                  Text(
                    "image quality".tr,
                  ),
                  SizedBox(
                    height: 50,
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: List.generate(
                        shareAsImageController.imageQulityList.length,
                        (index) => GestureDetector(
                          onTap: (() {
                            shareAsImageController.updateImageQuality(
                                shareAsImageController.imageQulityList[index]);
                          }),
                          child: Container(
                            width: 60,
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Card(
                              color: shareAsImageController
                                          .imageQulityList[index] ==
                                      shareAsImageController.imageQuality
                                  ? mainColor
                                  : null,
                              child: Center(
                                child: Text(
                                  shareAsImageController.imageQulityList[index]
                                      .toString(),
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Divider(),
                  CheckboxListTile(
                    title: Text("show zikr index".tr),
                    value: shareAsImageController.showZikrIndex,
                    onChanged: (value) {
                      shareAsImageController.toggleShowZikrIndex(value: value!);
                    },
                  ),
                  CheckboxListTile(
                    title: Text("show fadl".tr),
                    value: shareAsImageController.showFadl,
                    onChanged: (value) {
                      shareAsImageController.toggleShowFadl(value: value!);
                    },
                  ),
                  CheckboxListTile(
                    title: Text("show source of zikr".tr),
                    value: shareAsImageController.showSource,
                    onChanged: (value) {
                      shareAsImageController.toggleShowSource(value: value!);
                    },
                  ),
                  const Divider(),
                  CheckboxListTile(
                    title: Text("fixed size mode".tr),
                    value: shareAsImageController.fixedFont,
                    onChanged: (value) {
                      shareAsImageController.toggleFixedContentStatus(
                          value: value!);
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
