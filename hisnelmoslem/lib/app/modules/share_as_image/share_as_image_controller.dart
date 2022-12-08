import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/app/data/models/zikr_content.dart';
import 'package:hisnelmoslem/app/data/share_as_image_data.dart';
import 'package:hisnelmoslem/core/values/constant.dart';
import 'package:hisnelmoslem/app/shared/functions/print.dart';
import 'package:hisnelmoslem/app/modules/share_as_image/dialogs/image_width_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';

class ShareAsImageController extends GetxController {
  late DbContent initDbContent;
  ShareAsImageController({required DbContent dbContent}) {
    initDbContent = dbContent;
  }
  /* *************** Variables *************** */
  TransformationController transformationController =
      TransformationController();
  final DraggableScrollableController draggableScrollableController =
      DraggableScrollableController();
  final ScreenshotController screenshotController = ScreenshotController();

  // ******************************************* //
  bool isLoading = false;
  final box = GetStorage();

  DbContent get dbContent {
    hisnPrint("ShareAsImageController dbContent");
    hisnPrint(shareAsImageData.removeTashkel);
    DbContent temp = initDbContent;
    hisnPrint(temp);
    if (shareAsImageData.removeTashkel) {
      temp = removeTashkelDBcontent();
    }
    hisnPrint(temp);
    return temp;
  }

  // ******************************************* //
  double dividerSize = 3;
  double titleFactor = .8;
  double fadlFactor = .8;
  double sourceFactor = .7;

  // ******************************************* //

  // ******************************************* //

  late List<Color> colorsListForText,
      backgroundColors,
      titleColorsList,
      bodyColorsList,
      additionalTextColorsList;

  final List<double> imageQulityList = [1.0, 1.5, 2.0, 2.5, 3];

  /* *************** Controller life cycle *************** */
//
  @override
  void onInit() {
    super.onInit();
    backgroundColors = titleColorsList = bodyColorsList =
        additionalTextColorsList = colorsListForText = shareAsImageColorsList;
    fitImageToScreen();
  }

  //
  @override
  void onClose() {
    transformationController.dispose();
    super.onClose();
  }

  /* *************** Functions *************** */

  updateTextColor(Color color) async {
    await box.write(shareAsImageData.bodyTextColorBoxKey, color.value);
    update();
  }

  updateTitleColor(Color color) async {
    await box.write(shareAsImageData.titleTextBoxKey, color.value);
    update();
  }

  updateBackgroundColor(Color color) async {
    await box.write(shareAsImageData.backgroundColorBoxKey, color.value);
    update();
  }

  updateAdditionalTextColor(Color color) async {
    await box.write(shareAsImageData.additionalTextColorBoxKey, color.value);
    update();
  }

  void showColorPicker({required Color initialColor}) {}

  // ******************************************* //
  void changFontSize(double value) async {
    value = value.clamp(10, 70);
    await box.write(shareAsImageData.fontSizeBoxKey, value);
    update();
  }

  increaseFontSize() {
    changFontSize(shareAsImageData.fontSize + 1);
  }

  decreaseFontSize() {
    changFontSize(shareAsImageData.fontSize - 1);
  }

  resetFontSize() {
    changFontSize(25);
  }

  // ******************************************* //
  void updateImageQuality(double value) async {
    await box.write(shareAsImageData.imageQualityBoxKey, value);
    update();
  }

  shareImage() async {
    try {
      isLoading = true;
      update();
      await screenshotController
          .capture(pixelRatio: shareAsImageData.imageQuality)
          .then((Uint8List? image) async {
        final tempDir = await getTemporaryDirectory();
        //
        File file =
            await File('${tempDir.path}/hisnElmoslemSharedImage.png').create();
        //
        file.writeAsBytesSync(image!);
        //
        await Share.shareFiles([file.path]);
        isLoading = false;
        update();
      }).catchError((onError) {});
      //

    } catch (e) {
      hisnPrint(e.toString());
    }
  }

  // ******************************************* //
  toggleShowFadl({required bool value}) async {
    await box.write(shareAsImageData.showFadlBoxKey, value);
    update();
  }

  toggleShowSource({required bool value}) async {
    await box.write(shareAsImageData.showSourceBoxKey, value);

    update();
  }

  toggleShowZikrIndex({required bool value}) async {
    await box.write(shareAsImageData.showZikrIndexBoxKey, value);
    update();
  }

  toggleRemoveTashkel() async {
    await box.write(
        shareAsImageData.removeTashkelKey, !shareAsImageData.removeTashkel);
    hisnPrint(shareAsImageData.removeTashkel);
    update();
  }

  // ******************************************* //
  toggleFixedContentStatus({required bool value}) async {
    await box.write(shareAsImageData.fixedFontBoxKey, value);
    fitImageToScreen();
    update();
  }

  // ******************************************* //
  updateImageWidth({required int value}) async {
    await box.write(shareAsImageData.imageWidthBoxKey, value);
    fitImageToScreen();
    update();
  }

  ///
  showImageWidthDialog() async {
    await showDialog(
      barrierDismissible: true,
      context: Get.context!,
      builder: (BuildContext context) {
        return ImageWidthDialog(
          initialValue: shareAsImageData.imageWidth.toString(),
          onSubmit: (width) async {
            try {
              int tempWidth = 0;
              tempWidth = int.tryParse(width)!;
              updateImageWidth(value: tempWidth);
            } catch (e) {
              updateImageWidth(value: shareAsImageData.imageWidth);
            }
          },
        );
      },
    );
  }

  // ******************************************* //
  void fitImageToScreen() {
    double screenWidth = MediaQuery.of(Get.context!).size.width;
    // double _screenHeight = MediaQuery.of(Get.context!).size.height;
    double scale = 0;
    scale = screenWidth / shareAsImageData.imageWidth;

    /// create fitMatrix
    Matrix4 fitMatrix = Matrix4.diagonal3Values(scale, scale, scale);

    /// set x
    fitMatrix[12] = 0;

    /// set y
    /// center vertically
    // _fitMatrix[13] = _screenHeight / 4;

    /// set fitMatrix to transformation
    transformationController.value = fitMatrix;
  }

  DbContent removeTashkelDBcontent() {
    DbContent temp = DbContent.fromMap(initDbContent.toMap());
    temp.content = temp.content
        .replaceAll(RegExp(String.fromCharCodes(arabicTashkelChar)), "");
    temp.fadl = temp.fadl
        .replaceAll(RegExp(String.fromCharCodes(arabicTashkelChar)), "");
    temp.source = temp.source
        .replaceAll(RegExp(String.fromCharCodes(arabicTashkelChar)), "");

    return temp;
  }
}
