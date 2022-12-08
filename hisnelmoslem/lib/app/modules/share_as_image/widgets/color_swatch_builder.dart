import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/core/values/constant.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ColorSwatchBuilder extends StatelessWidget {
  final List<Color> colorSwatchList;
  final Color colorToTrack;
  final void Function(Color color) apply;

  const ColorSwatchBuilder({
    Key? key,
    required this.colorSwatchList,
    required this.colorToTrack,
    required this.apply,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color tempColor = colorToTrack;
    void changeColor(Color color) {
      tempColor = color;
    }

    return SizedBox(
      height: 40,
      child: Row(
        children: [
          IconButton(
            color: colorToTrack,
            splashRadius: 20,
            iconSize: 30,
            onPressed: () {
              showDialog(
                barrierDismissible: true,
                context: Get.context!,
                builder: (BuildContext context) {
                  return Center(
                    child: SizedBox(
                      width: 300,
                      child: SingleChildScrollView(
                        child: Card(
                          margin: const EdgeInsets.all(20),
                          clipBehavior: Clip.hardEdge,
                          child: Column(
                            children: [
                              ColorPicker(
                                colorPickerWidth: 300,
                                displayThumbColor: true,
                                paletteType: PaletteType.hsvWithSaturation,
                                colorHistory: colorSwatchList,
                                labelTypes: const [],
                                enableAlpha: false,
                                pickerColor: colorToTrack,
                                onColorChanged: changeColor,
                                onHistoryChanged: (value) {},
                              ),
                              ListTile(
                                tileColor: mainColor,
                                onTap: () {
                                  apply(tempColor);
                                  Navigator.pop(context);
                                },
                                title: const Text(
                                  "اختر هذا اللون",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 25),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            icon: const Icon(MdiIcons.brush),
          ),
        ],
      ),
    );
  }
}
