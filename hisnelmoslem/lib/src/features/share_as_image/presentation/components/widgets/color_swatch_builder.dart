import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ColorSwatchBuilder extends StatelessWidget {
  final List<Color> colorSwatchList;
  final Color colorToTrack;
  final void Function(Color color) apply;

  const ColorSwatchBuilder({
    super.key,
    required this.colorSwatchList,
    required this.colorToTrack,
    required this.apply,
  });

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
                                onTap: () {
                                  apply(tempColor);
                                  Navigator.pop(context);
                                },
                                title: Text(
                                  "Select color".tr,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 25),
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
            icon: Icon(MdiIcons.brush),
          ),
        ],
      ),
    );
  }
}
