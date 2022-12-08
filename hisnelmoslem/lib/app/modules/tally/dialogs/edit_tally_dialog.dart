import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/app/data/models/tally.dart';
import 'package:hisnelmoslem/app/shared/functions/show_toast.dart';
import 'package:hisnelmoslem/core/values/constant.dart';
import 'package:hisnelmoslem/app/shared/custom_inputs/number_field.dart';
import 'package:hisnelmoslem/app/shared/custom_inputs/text_field.dart';
import 'package:hisnelmoslem/app/shared/dialogs/dialog_maker.dart';

class EditTallyDialog extends StatefulWidget {
  final DbTally dbTally;
  final Function(DbTally) onSubmit;

  const EditTallyDialog({
    Key? key,
    required this.dbTally,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<EditTallyDialog> createState() => _EditTallyDialogState();
}

class _EditTallyDialogState extends State<EditTallyDialog> {
  TextEditingController titleController = TextEditingController();

  TextEditingController resetCounterController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    titleController = TextEditingController(text: widget.dbTally.title);
    resetCounterController =
        TextEditingController(text: widget.dbTally.countReset.toString());
    return DialogMaker(
      height: 350,
      header: Text(
        "edit counter".tr,
        style: TextStyle(
          fontSize: 25,
          color: mainColor,
        ),
      ),
      content: [
        Text(
          "add a name to your counter".tr,
          textAlign: TextAlign.center,
        ),
        UserTextField(
          controller: titleController,
          hintText: "counter name".tr,
        ),
        Text(
          "the counter circle is set to zero when reach this number".tr,
          textAlign: TextAlign.center,
        ),
        UserNumberField(
          controller: resetCounterController,
          hintText: "circle every".tr,
        ),
      ],
      footer: ListTile(
        title: Text(
          "done".tr,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, color: mainColor),
        ),
        onTap: () {
          if (resetCounterController.text.isNum &&
              int.parse(resetCounterController.text) > 0) {
            widget.dbTally.title = titleController.text;
            widget.dbTally.countReset = int.parse(resetCounterController.text);
            widget.onSubmit(widget.dbTally);
            Navigator.pop<bool>(context, true);
          } else {
            showToast(msg: "Counter circle must be greater than zero".tr);
          }
        },
      ),
    );
  }
}
