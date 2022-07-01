import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/shared/constants/constant.dart';
import 'package:hisnelmoslem/shared/functions/print.dart';
import 'package:hisnelmoslem/views/share_as_image/dialogs/image_width_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';

class ShareAsImageController extends GetxController {
  /* *************** Variables *************** */
  TransformationController transformationController =
      TransformationController();
  final DraggableScrollableController draggableScrollableController =
      DraggableScrollableController();
  final ScreenshotController screenshotController = ScreenshotController();

  // ******************************************* //
  bool isLoading = false;
  final box = GetStorage();

  // ******************************************* //
  double dividerSize = 3;
  double titleFactor = .8;
  double fadlFactor = .8;
  double sourceFactor = .7;

  // ******************************************* //
  final String titleTextBoxKey = 'share_image_title_text_color';
  Color get titleTextColor =>
      Color(box.read<int?>(titleTextBoxKey) ?? colorsList[4].value);

  final String bodyTextColorBoxKey = 'share_image_body_text_color';
  Color get bodyTextColor =>
      Color(box.read<int?>(bodyTextColorBoxKey) ?? colorsList[5].value);

  final String additionalTextColorBoxKey = 'share_image_additional_text_color';
  Color get additionalTextColor =>
      Color(box.read<int?>(additionalTextColorBoxKey) ?? colorsList[3].value);

  final String backgroundColorBoxKey = 'share_image_background_color';
  Color get backgroundColor =>
      Color(box.read<int?>(backgroundColorBoxKey) ?? colorsList[9].value);

  final String fontSizeBoxKey = 'share_image_font_size';
  double get fontSize => box.read(fontSizeBoxKey) ?? 25;

  final String showFadlBoxKey = 'share_image_show_fadl';
  bool get showFadl => box.read(showFadlBoxKey) ?? true;

  final String showSourceBoxKey = 'share_image_show_source';
  bool get showSource => box.read(showSourceBoxKey) ?? true;

  final String showZikrIndexBoxKey = 'share_image_show_zikr_index';
  bool get showZikrIndex => box.read(showZikrIndexBoxKey) ?? true;

  final String fixedFontBoxKey = 'share_image_fixed_font';
  bool get fixedFont => box.read(fixedFontBoxKey) ?? false;

  final String imageWidthBoxKey = 'share_image_image_width';
  int get imageWidth => box.read(imageWidthBoxKey) ?? 600;

  final String imageQualityBoxKey = 'share_image_image_quality';
  double get imageQuality => box.read(imageQualityBoxKey) ?? 2;

  // ******************************************* //
  final List<Color> colorsList = [
    black,
    const Color.fromARGB(255, 66, 66, 66),
    const Color.fromARGB(255, 48, 48, 48),
    const Color.fromARGB(255, 163, 124, 92),
    brwon,
    const Color.fromARGB(255, 25, 26, 33),
    green,
    const Color.fromARGB(255, 1, 151, 159),
    Colors.amber,
    const Color.fromARGB(255, 255, 248, 238),
    const Color.fromARGB(255, 244, 246, 248),
    white,
  ];
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
        additionalTextColorsList = colorsListForText = colorsList;
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
    hisnPrint(color.toString());
    hisnPrint(Color(color.value).value.toString());
    await box.write(bodyTextColorBoxKey, color.value);
    update();
  }

  updateTitleColor(Color color) async {
    await box.write(titleTextBoxKey, color.value);
    update();
  }

  updateBackgroundColor(Color color) async {
    await box.write(backgroundColorBoxKey, color.value);
    update();
  }

  updateAdditionalTextColor(Color color) async {
    await box.write(additionalTextColorBoxKey, color.value);
    update();
  }

  void showColorPicker({required Color initialColor}) {}

  // ******************************************* //
  void changFontSize(double value) async {
    value = value.clamp(10, 50);
    await box.write(fontSizeBoxKey, value);
    update();
  }

  increaseFontSize() {
    changFontSize(fontSize + 1);
  }

  decreaseFontSize() {
    changFontSize(fontSize - 1);
  }

  resetFontSize() {
    changFontSize(25);
  }

  // ******************************************* //
  void updateImageQuality(double value) async {
    await box.write(imageQualityBoxKey, value);
    update();
  }

  shareImage() async {
    try {
      isLoading = true;
      update();
      await screenshotController
          .capture(pixelRatio: imageQuality)
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
    await box.write(showFadlBoxKey, value);
    update();
  }

  toggleShowSource({required bool value}) async {
    await box.write(showSourceBoxKey, value);

    update();
  }

  toggleShowZikrIndex({required bool value}) async {
    await box.write(showZikrIndexBoxKey, value);
    update();
  }

  // ******************************************* //
  toggleFixedContentStatus({required bool value}) async {
    await box.write(fixedFontBoxKey, value);
    fitImageToScreen();
    update();
  }

  // ******************************************* //
  updateImageWidth({required int value}) async {
    await box.write(imageWidthBoxKey, value);
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
          initialValue: imageWidth.toString(),
          onSubmit: (width) async {
            try {
              int _width = 0;
              _width = int.tryParse(width)!;
              updateImageWidth(value: _width);
            } catch (e) {
              updateImageWidth(value: imageWidth);
            }
          },
        );
      },
    );
  }

  // ******************************************* //
  void fitImageToScreen() {
    double _screenWidth = MediaQuery.of(Get.context!).size.width;
    // double _screenHeight = MediaQuery.of(Get.context!).size.height;
    double _scale = 0;
    _scale = _screenWidth / imageWidth;

    /// create fitMatrix
    Matrix4 _fitMatrix = Matrix4.diagonal3Values(_scale, _scale, _scale);

    /// set x
    _fitMatrix[12] = 0;

    /// set y
    /// center vertically
    // _fitMatrix[13] = _screenHeight / 4;

    /// set fitMatrix to transformation
    transformationController.value = _fitMatrix;
  }
}
