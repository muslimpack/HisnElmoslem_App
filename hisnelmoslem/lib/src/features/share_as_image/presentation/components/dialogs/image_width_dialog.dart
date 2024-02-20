import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        "ُEdit image size".tr,
        style: const TextStyle(
          fontSize: 25,
        ),
      ),
      content: [
        Text(
          "Image width".tr,
          textAlign: TextAlign.center,
        ),
        UserNumberField(
          controller: widthController,
          hintText: "Image width".tr,
        ),
      ],
      footer: ListTile(
        title: Text(
          "done".tr,
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
