import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/functions/show_toast.dart';
import 'package:hisnelmoslem/src/core/models/editor_result.dart';
import 'package:hisnelmoslem/src/core/shared/custom_inputs/number_field.dart';
import 'package:hisnelmoslem/src/core/shared/custom_inputs/text_field.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally.dart';

Future<EditorResult<DbTally>?> showTallyEditorDialog({
  required BuildContext context,
  DbTally? dbTally,
}) async {
  return showDialog<EditorResult<DbTally>?>(
    context: context,
    builder: (BuildContext context) {
      return TallyEditor(
        dbTally: dbTally,
      );
    },
  );
}

class TallyEditor extends StatefulWidget {
  final DbTally? dbTally;

  const TallyEditor({
    super.key,
    this.dbTally,
  });

  @override
  State<TallyEditor> createState() => _TallyEditorState();
}

class _TallyEditorState extends State<TallyEditor> {
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
    return AlertDialog(
      title: Text(
        () {
          if (widget.dbTally != null) {
            return S.of(context).editCounter;
          } else {
            return S.of(context).addNewCounter;
          }
        }(),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
      ),
      actions: [
        if (widget.dbTally != null)
          TextButton(
            child: Text(
              S.of(context).delete,
              style: TextStyle(
                color: Theme.of(context).buttonTheme.colorScheme?.error,
              ),
            ),
            onPressed: () {
              Navigator.pop(
                context,
                EditorResult(action: EditorActionEnum.delete, value: dbTally),
              );
            },
          ),
        FilledButton(
          child: Text(
            widget.dbTally == null ? S.of(context).add : S.of(context).edit,
            textAlign: TextAlign.center,
          ),
          onPressed: () {
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

            if (dbTally == widget.dbTally) {
              Navigator.pop(context);
              return;
            }

            Navigator.pop(
              context,
              EditorResult(
                action: widget.dbTally == null
                    ? EditorActionEnum.add
                    : EditorActionEnum.edit,
                value: dbTally,
              ),
            );
          },
        ),
      ],
    );
  }
}
