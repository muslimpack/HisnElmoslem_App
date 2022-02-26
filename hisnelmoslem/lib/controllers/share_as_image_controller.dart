import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/shared/constants/constant.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';

class ShareAsImageController extends GetxController {
  /* *************** Variables *************** */
  //
  Uint8List? imageFile;
  //
  TransformationController transformationController =
      new TransformationController();
  //
  Color textColor = brwon;
  Color titleColor = brwon;
  Color backgroundColor = white;
  Color dividerColor = green;
  Color appNameColor = MAINCOLOR;
  //
  bool bInvert = false;
  bool showFadl = true;
  bool showSource = true;
  //
  final ScreenshotController screenshotController = ScreenshotController();
  //

  /* *************** Controller life cycle *************** */
  //
  @override
  void onInit() {
    super.onInit();
  }

  //
  @override
  void onClose() {
    super.onClose();
    transformationController.dispose();
  }

  /* *************** Functions *************** */
  //
  invertColor() {
    bInvert = !bInvert;
    if (bInvert) {
      textColor = Colors.white.withOpacity(.8);
      titleColor = Color.fromARGB(255, 204, 171, 101);
      dividerColor = white.withOpacity(.2);

      backgroundColor = Color.fromARGB(255, 39, 31, 28);
      appNameColor = Color.fromARGB(255, 204, 171, 101);
    } else {
      textColor = brwon;
      titleColor = brwon;
      backgroundColor = white;
      dividerColor = green;
      appNameColor = MAINCOLOR;
    }

    update();
  }

  //
  convertToImage() async {
    await screenshotController.capture().then((Uint8List? image) {
      imageFile = image;
    }).catchError((onError) {
      debugPrint(onError);
    });
    update();
  }

  shareImage() async {
    try {
      //
      await convertToImage();
      //
      final tempDir = await getTemporaryDirectory();
      //
      File file =
          await File('${tempDir.path}/hisnElmoslemSharedImage.png').create();
      //
      file.writeAsBytesSync(imageFile!);
      //
      await Share.shareFiles([file.path]);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  //
  toggleShowFadl({required bool value}) {
    showFadl = value;
    update();
  }

  //
  toggleShowSource({required bool value}) {
    showSource = value;
    update();
  }
}
