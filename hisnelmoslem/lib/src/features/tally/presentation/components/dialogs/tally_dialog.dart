import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/shared/custom_inputs/number_field.dart';
import 'package:hisnelmoslem/src/core/shared/custom_inputs/text_field.dart';
import 'package:hisnelmoslem/src/core/shared/dialogs/dialog_maker.dart';
import 'package:hisnelmoslem/src/core/utils/show_toast.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally.dart';

class TallyDialog extends StatefulWidget {
  final DbTally dbTally;
  final Function(DbTally) onSubmit;
  final bool isToEdit;
  const TallyDialog({
    super.key,
    required this.dbTally,
    required this.onSubmit,
    required this.isToEdit,
  });

  @override
  State<TallyDialog> createState() => _TallyDialogState();
}

class _TallyDialogState extends State<TallyDialog> {
  TextEditingController titleController = TextEditingController();
  TextEditingController resetCounterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isToEdit) {
      titleController = TextEditingController(text: widget.dbTally.title);
      resetCounterController =
          TextEditingController(text: widget.dbTally.countReset.toString());
    } else {
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
          if (widget.isToEdit) {
            return S.of(context).edit_counter;
          } else {
            return S.of(context).add_new_counter;
          }
        }(),
        style: TextStyle(
          fontSize: 25,
          color: mainColor,
        ),
      ),
      content: [
        Text(
          S.of(context).add_a_name_to_your_counter,
          textAlign: TextAlign.center,
        ),
        UserTextField(
          controller: titleController,
          hintText: S.of(context).counter_name,
        ),
        Text(
          S.of(context).counter_circle_set_to_zero_when_reach_this_number,
          textAlign: TextAlign.center,
        ),
        UserNumberField(
          controller: resetCounterController,
          hintText: S.of(context).circle_every,
        ),
      ],
      footer: ListTile(
        title: Text(
          S.of(context).done,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, color: mainColor),
        ),
        onTap: () {
          if (resetCounterController.text.isNum &&
              int.parse(resetCounterController.text) > 0) {
            if (widget.isToEdit) {
              widget.dbTally.title = titleController.text;
              widget.dbTally.countReset =
                  int.parse(resetCounterController.text);
              widget.onSubmit(widget.dbTally);
              Navigator.pop<bool>(context, true);
            } else {
              final DbTally dbTally = DbTally();
              dbTally.title = titleController.text;
              dbTally.countReset = int.parse(resetCounterController.text);
              widget.onSubmit(dbTally);
              Navigator.pop<bool>(context, true);
            }
          } else {
            showToast(
              msg: S.of(context).counter_circle_must_be_greater_than_zero,
            );
          }
        },
      ),
    );
  }
}
