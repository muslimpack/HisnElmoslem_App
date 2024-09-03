import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/functions/show_toast.dart';
import 'package:hisnelmoslem/src/core/shared/custom_inputs/number_field.dart';
import 'package:hisnelmoslem/src/core/shared/custom_inputs/text_field.dart';
import 'package:hisnelmoslem/src/core/shared/dialogs/dialog_maker.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally.dart';

class TallyDialog extends StatefulWidget {
  final DbTally? dbTally;

  const TallyDialog({
    super.key,
    this.dbTally,
  });

  @override
  State<TallyDialog> createState() => _TallyDialogState();
}

class _TallyDialogState extends State<TallyDialog> {
  late DbTally dbTally;
  TextEditingController titleController = TextEditingController();
  TextEditingController resetCounterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.dbTally != null) {
      dbTally = widget.dbTally!;
      titleController = TextEditingController(text: dbTally.title);
      resetCounterController =
          TextEditingController(text: dbTally.countReset.toString());
    } else {
      dbTally = DbTally.empty(
        created: DateTime.now(),
        lastUpdate: DateTime.now(),
      );
      titleController = TextEditingController();
      resetCounterController = TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogMaker(
      height: 350,
      header: Text(
        () {
          if (widget.dbTally != null) {
            return "edit counter".tr;
          } else {
            return "add new counter".tr;
          }
        }(),
        style: const TextStyle(
          fontSize: 25,
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
          style: const TextStyle(fontSize: 20),
        ),
        onTap: () {
          final String title = titleController.text.trim();
          final int? resetCounter = int.tryParse(resetCounterController.text);
          if (title.isEmpty) {
            return;
          }
          if (resetCounter == null || title.isEmpty) {
            showToast(msg: "Counter circle must be greater than zero".tr);
            return;
          }

          dbTally = dbTally.copyWith(title: title, countReset: resetCounter);

          Navigator.pop<DbTally>(context, dbTally);
        },
      ),
    );
  }
}
