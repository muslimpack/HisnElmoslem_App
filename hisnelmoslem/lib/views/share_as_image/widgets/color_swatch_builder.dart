import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/shared/constants/constant.dart';
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
    bool checkIfColorIsPicked() {
      for (var color in colorSwatchList) {
        if (color.value == colorToTrack.value) {
          return true;
        }
      }
      return false;
    }

    bool isPickedColor = false;
    isPickedColor = checkIfColorIsPicked();
    Color tempColor = colorToTrack;
    void changeColor(Color color) {
      tempColor = color;
    }

    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Container(
            color: !isPickedColor ? mainColor : null,
            child: IconButton(
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
                                  labelTypes: const [],
                                  enableAlpha: false,
                                  pickerColor: colorToTrack,
                                  onColorChanged: changeColor,
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
                            // actions: <Widget>[
                            //   ListTile(
                            //     onTap: () {},
                            //     title: const Text(
                            //       "تم",
                            //       textAlign: TextAlign.center,
                            //       style: TextStyle(fontSize: 25),
                            //     ),
                            //   ),
                            // ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              icon: const Icon(MdiIcons.paletteOutline),
            ),
          ),
          const VerticalDivider(),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: [
                ...List.generate(
                  colorSwatchList.length,
                  (index) => GestureDetector(
                    onTap: (() {
                      apply(colorSwatchList[index]);
                    }),
                    child: Container(
                      color: colorSwatchList[index].value == colorToTrack.value
                          ? mainColor
                          : null,
                      width: 40,
                      child: Card(
                        color: colorSwatchList[index],
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
