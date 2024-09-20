import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_color.dart';

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
    return GestureDetector(
      onTap: () async {
        final Color? selectColorDialog = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return SelectColorDialog(
              colorHistory: colorSwatchList,
              color: colorToTrack,
            );
          },
        );
        if (selectColorDialog == null) return;
        apply.call(selectColorDialog);
      },
      child: Card(
        color: colorToTrack,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            title,
            style: TextStyle(color: colorToTrack.getContrastColor),
          ),
        ),
      ),
    );
  }
}

class SelectColorDialog extends StatelessWidget {
  const SelectColorDialog({
    super.key,
    required this.colorHistory,
    required this.color,
  });

  final List<Color> colorHistory;
  final Color color;

  @override
  Widget build(BuildContext context) {
    Color tempColor = color;
    return AlertDialog(
      clipBehavior: Clip.hardEdge,
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ColorPicker(
            displayThumbColor: true,
            paletteType: PaletteType.hsvWithSaturation,
            colorHistory: colorHistory,
            labelTypes: const [],
            enableAlpha: false,
            hexInputBar: true,
            pickerColor: color,
            onColorChanged: (value) {
              tempColor = value;
            },
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () {
            Navigator.pop(context, tempColor);
          },
          child: Text(S.of(context).selectColor),
        ),
      ],
    );
  }
}
