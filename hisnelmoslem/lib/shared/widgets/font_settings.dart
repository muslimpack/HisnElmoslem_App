import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../controllers/app_data_controllers.dart';
import '../constants/constant.dart';

class FontSettingsToolbox extends StatelessWidget {
  final GetxController controllerToUpdate;
  final bool showFontResizeControllers;
  final bool showTashkelControllers;
  const FontSettingsToolbox({
    Key? key,
    required this.controllerToUpdate,
    this.showFontResizeControllers = true,
    this.showTashkelControllers = true,
  }) : super(key: key);
  static AppDataController appDataController = Get.put(AppDataController());
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        // mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Visibility(
            visible: showFontResizeControllers,
            child: Expanded(
                flex: 1,
                child: IconButton(
                    icon: Icon(MdiIcons.restart),
                    onPressed: () {
                      appDataController.resetFontSize();
                      controllerToUpdate.update();
                    })),
          ),
          Visibility(
            visible: showFontResizeControllers,
            child: Expanded(
                flex: 1,
                child: IconButton(
                    icon: Icon(MdiIcons.formatFontSizeIncrease),
                    onPressed: () {
                      appDataController.increaseFontSize();
                      controllerToUpdate.update();
                    })),
          ),
          Visibility(
            visible: showFontResizeControllers,
            child: Expanded(
                flex: 1,
                child: IconButton(
                    icon: Icon(MdiIcons.formatFontSizeDecrease),
                    onPressed: () {
                      appDataController.decreaseFontSize();
                      controllerToUpdate.update();
                    })),
          ),
          Visibility(
            visible: showTashkelControllers,
            child: Expanded(
                flex: 1,
                child: IconButton(
                    icon: Icon(MdiIcons.abjadArabic),
                    onPressed: () {
                      appDataController.toggleTashkelStatus();
                      controllerToUpdate.update();
                    })),
          ),
        ],
      ),
    );
  }
}

class TextSample extends StatelessWidget {
  const TextSample({Key? key}) : super(key: key);
  static AppDataController appDataController = Get.put(AppDataController());
  static String text = "اِلْبَسْ جَدِيداً وَعِشْ حَمِيداً وَمُتْ شَهِيداً";
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Text(
              appDataController.isTashkelEnabled
                  ? text
                  : text.replaceAll(
                      new RegExp(String.fromCharCodes(arabicTashkelChar)), ""),
              textAlign: TextAlign.center,
              softWrap: true,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                  fontSize: appDataController.fontSize * 10,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
