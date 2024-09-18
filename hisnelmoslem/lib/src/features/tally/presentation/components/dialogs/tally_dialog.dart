import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
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
            return S.of(context).editCounter;
          } else {
            return S.of(context).addNewCounter;
          }
        }(),
        style: const TextStyle(
          fontSize: 25,
        ),
      ),
      content: [
        Text(
          S.of(context).addNameToCounter,
          textAlign: TextAlign.center,
        ),
        UserTextField(
          controller: titleController,
          hintText: S.of(context).counterName,
        ),
        Text(
          S.of(context).counterCircleSetToZero,
          textAlign: TextAlign.center,
        ),
        UserNumberField(
          controller: resetCounterController,
          hintText: S.of(context).circleEvery,
        ),
      ],
      footer: ListTile(
        title: Text(
          S.of(context).done,
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
            showToast(msg: S.of(context).counterCircleMustBeGreaterThanZero);
            return;
          }

          dbTally = dbTally.copyWith(title: title, countReset: resetCounter);

          Navigator.pop<DbTally>(context, dbTally);
        },
      ),
    );
  }
}
