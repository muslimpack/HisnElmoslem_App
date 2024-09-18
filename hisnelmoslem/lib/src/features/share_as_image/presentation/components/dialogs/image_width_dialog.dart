import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/shared/custom_inputs/number_field.dart';
import 'package:hisnelmoslem/src/core/shared/dialogs/dialog_maker.dart';

class ImageWidthDialog extends StatelessWidget {
  final Function(String) onSubmit;
  final String initialValue;

  const ImageWidthDialog({
    super.key,
    required this.onSubmit,
    required this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController widthController =
        TextEditingController(text: initialValue);
    return DialogMaker(
      height: 270,
      header: Text(
        S.of(context).editImageSize,
        style: const TextStyle(
          fontSize: 25,
        ),
      ),
      content: [
        Text(
          S.of(context).imageWidth,
          textAlign: TextAlign.center,
        ),
        UserNumberField(
          controller: widthController,
          hintText: S.of(context).imageWidth,
        ),
      ],
      footer: ListTile(
        title: Text(
          S.of(context).done,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20),
        ),
        onTap: () {
          onSubmit(widthController.text);
          Navigator.pop<bool>(context, true);
        },
      ),
    );
  }
}
