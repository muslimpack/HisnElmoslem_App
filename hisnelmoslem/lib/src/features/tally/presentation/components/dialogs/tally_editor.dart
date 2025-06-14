import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/functions/show_toast.dart';
import 'package:hisnelmoslem/src/core/models/editor_result.dart';
import 'package:hisnelmoslem/src/core/shared/custom_inputs/number_field.dart';
import 'package:hisnelmoslem/src/core/shared/custom_inputs/text_field.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

Future<EditorResult<DbTally>?> showTallyEditorDialog({
  required BuildContext context,
  DbTally? dbTally,
}) {
  return showDialog<EditorResult<DbTally>?>(
    context: context,
    builder: (BuildContext context) {
      return _TallyEditor(dbTally: dbTally);
    },
  );
}

class _TallyEditor extends StatefulWidget {
  final DbTally? dbTally;

  const _TallyEditor({this.dbTally});

  @override
  State<_TallyEditor> createState() => _TallyEditorState();
}

class _TallyEditorState extends State<_TallyEditor> {
  late DbTally dbTally;
  TextEditingController titleController = TextEditingController();
  TextEditingController resetCounterController = TextEditingController();
  TextEditingController counterValueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.dbTally != null) {
      dbTally = widget.dbTally!;
      titleController = TextEditingController(text: dbTally.title);
      resetCounterController = TextEditingController(
        text: dbTally.countReset.toString(),
      );
      counterValueController = TextEditingController(
        text: dbTally.count.toString(),
      );
    } else {
      dbTally = DbTally.empty(
        created: DateTime.now(),
        lastUpdate: DateTime.now(),
      );
      titleController = TextEditingController();
      resetCounterController = TextEditingController();
      counterValueController = TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).tallyEditor),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(S.of(context).addNameToCounter, textAlign: TextAlign.center),
            UserTextField(
              autoFocus: true,
              controller: titleController,
              hintText: S.of(context).counterName,
            ),
            Text(
              S.of(context).counterCircleSetToZero,
              textAlign: TextAlign.center,
            ),
            UserNumberField(
              controller: resetCounterController,
              leadingIcon: MdiIcons.restore,
              hintText: S.of(context).circleEvery,
            ),
            Text(
              S.of(context).tallyActualCounterDesc,
              textAlign: TextAlign.center,
            ),
            UserNumberField(
              controller: counterValueController,
              leadingIcon: MdiIcons.counter,
              hintText: S.of(context).count,
            ),
          ],
        ),
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
          onPressed: onSubmit,
          child: Text(
            widget.dbTally == null ? S.of(context).add : S.of(context).edit,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Future onSubmit() async {
    final String title = titleController.text.trim();
    final int? resetCounter = int.tryParse(resetCounterController.text);
    final int? count = int.tryParse(counterValueController.text);
    if (title.isEmpty) {
      return;
    }
    if (resetCounter == null || title.isEmpty || count == null) {
      showToast(msg: S.of(context).counterCircleMustBeGreaterThanZero);
      return;
    }

    dbTally = dbTally.copyWith(
      title: title,
      countReset: resetCounter,
      count: count,
    );

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
  }
}
