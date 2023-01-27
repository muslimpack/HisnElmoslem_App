import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/app/data/app_data.dart';
import 'package:hisnelmoslem/core/values/constant.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class FontSettingsToolbox extends StatelessWidget {
  final GetxController controllerToUpdate;
  final bool showFontResizeControllers;
  final bool showTashkelControllers;

  const FontSettingsToolbox({
    super.key,
    required this.controllerToUpdate,
    this.showFontResizeControllers = true,
    this.showTashkelControllers = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      // mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Visibility(
          visible: showFontResizeControllers,
          child: Expanded(
            flex: 1,
            child: IconButton(
                icon: const Icon(MdiIcons.restart),
                onPressed: () {
                  appData.resetFontSize();
                  controllerToUpdate.update();
                }),
          ),
        ),
        Visibility(
          visible: showFontResizeControllers,
          child: Expanded(
            flex: 1,
            child: IconButton(
                icon: const Icon(MdiIcons.formatFontSizeIncrease),
                onPressed: () {
                  appData.increaseFontSize();
                  controllerToUpdate.update();
                }),
          ),
        ),
        Visibility(
          visible: showFontResizeControllers,
          child: Expanded(
            flex: 1,
            child: IconButton(
                icon: const Icon(MdiIcons.formatFontSizeDecrease),
                onPressed: () {
                  appData.decreaseFontSize();
                  controllerToUpdate.update();
                }),
          ),
        ),
        Visibility(
          visible: showTashkelControllers,
          child: Expanded(
              flex: 1,
              child: IconButton(
                  icon: const Icon(MdiIcons.abjadArabic),
                  onPressed: () {
                    appData.toggleTashkelStatus();
                    controllerToUpdate.update();
                  })),
        ),
      ],
    );
  }
}

class TextSample extends StatelessWidget {
  final GetxController controllerToUpdate;

  const TextSample({super.key, required this.controllerToUpdate});
  static String text =
      "سُبْحَانَكَ اللَّهُمَّ رَبَّنَا وَبِحَمْدِكَ، اللَّهُمَّ اغْفِرْ لِي";

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Text(
              appData.isTashkelEnabled
                  ? text
                  : text.replaceAll(
                      RegExp(String.fromCharCodes(arabicTashkelChar)), ""),
              textAlign: TextAlign.center,
              softWrap: true,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                  fontSize: appData.fontSize * 10, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
