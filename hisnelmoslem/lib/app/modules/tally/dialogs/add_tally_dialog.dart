import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/app/data/models/tally.dart';
import 'package:hisnelmoslem/core/values/constant.dart';
import 'package:hisnelmoslem/app/shared/custom_inputs/number_field.dart';
import 'package:hisnelmoslem/app/shared/custom_inputs/text_field.dart';
import 'package:hisnelmoslem/app/shared/dialogs/dialog_maker.dart';

class AddTallyDialog extends StatelessWidget {
  final Function(DbTally) onSubmit;

  AddTallyDialog({
    Key? key,
    required this.onSubmit,
  }) : super(key: key);
  final TextEditingController titleController = TextEditingController();
  final TextEditingController resetCounterController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DialogMaker(
      height: 350,
      header: Text(
        "add new counter".tr,
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
          DbTally dbTally = DbTally();
          dbTally.title = titleController.text;
          dbTally.countReset = int.parse(resetCounterController.text);
          onSubmit(dbTally);
          Navigator.pop<bool>(context, true);
        },
      ),
    );
  }
}
