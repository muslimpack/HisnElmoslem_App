import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/shared/custom_inputs/number_field.dart';

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
    return AlertDialog(
      title: Text(
        S.of(context).editImageSize,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            S.of(context).imageWidth,
            textAlign: TextAlign.center,
          ),
          UserNumberField(
            controller: widthController,
            hintText: S.of(context).imageWidth,
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text(
            S.of(context).done,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20),
          ),
          onPressed: () {
            onSubmit(widthController.text);
            Navigator.pop<bool>(context, true);
          },
        ),
      ],
    );
  }
}
