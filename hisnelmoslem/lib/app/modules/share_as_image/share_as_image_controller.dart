import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/app/data/models/zikr_content.dart';
import 'package:hisnelmoslem/app/data/share_as_image_data.dart';
import 'package:hisnelmoslem/core/utils/azkar_database_helper.dart';
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
  bool pageIsLoading = true;
  final box = GetStorage();
  String title = "";

  Future<void> getTitle() async {
    if (dbContent.titleId >= 0) {
      await azkarDatabaseHelper
          .getTitleById(id: dbContent.titleId)
          .then((value) {
        title = value.name;
      });
    } else {
      title = "أحاديث منتشرة لا تصح";
    }
  }

  String get getImageTitle {
    if (dbContent.titleId >= 0) {
      if (shareAsImageData.showZikrIndex) {
        return "$title | ذكر رقم ${dbContent.orderId}";
      } else {
        return title;
      }
    } else {
      if (shareAsImageData.showZikrIndex) {
        return "$title | موضوع رقم ${dbContent.orderId}";
      } else {
        return title;
      }
    }
  }

  DbContent get dbContent {
    DbContent temp = initDbContent;
    if (shareAsImageData.removeTashkel) {
      temp = removeTashkelDBcontent();
    }
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
  void onInit() async {
    super.onInit();
    await getTitle();
    backgroundColors = titleColorsList = bodyColorsList =
        additionalTextColorsList = colorsListForText = shareAsImageColorsList;
    fitImageToScreen();
    pageIsLoading = false;
    update();
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
