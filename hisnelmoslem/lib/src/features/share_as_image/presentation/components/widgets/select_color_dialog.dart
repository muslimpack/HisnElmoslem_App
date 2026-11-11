import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';

/// Full color picker with a history row. Pops with the chosen color.
class SelectColorDialog extends StatelessWidget {
  const SelectColorDialog({
    super.key,
    required this.colorHistory,
    required this.color,
  });

  final List<Color> colorHistory;
  final Color color;

  /// Resolves to the chosen color, or null when dismissed.
  static Future<Color?> show(
    BuildContext context, {
    required List<Color> colorHistory,
    required Color color,
  }) {
    return showDialog<Color>(
      context: context,
      builder: (_) => SelectColorDialog(colorHistory: colorHistory, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color tempColor = color;
    return AlertDialog(
      clipBehavior: Clip.hardEdge,
      contentPadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        child: ColorPicker(
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
