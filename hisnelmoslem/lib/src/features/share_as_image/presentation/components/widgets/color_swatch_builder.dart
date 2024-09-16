import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';

class ColorSwatchBuilder extends StatelessWidget {
  final String title;
  final List<Color> colorSwatchList;
  final Color colorToTrack;
  final void Function(Color color) apply;

  const ColorSwatchBuilder({
    super.key,
    required this.title,
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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: Icon(
          Icons.brush,
          color: colorToTrack,
        ),
        title: Text(title),
        tileColor: colorToTrack.withOpacity(.2),
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Center(
                child: SizedBox(
                  width: 350,
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
      ),
    );
  }
}
