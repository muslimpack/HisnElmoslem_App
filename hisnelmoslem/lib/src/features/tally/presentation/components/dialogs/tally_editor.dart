import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
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
  late DbTally _dbTally;
  late final TextEditingController _titleController;
  late final TextEditingController _resetCounterController;
  late final TextEditingController _counterValueController;
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    if (widget.dbTally != null) {
      _dbTally = widget.dbTally!;
      _titleController = TextEditingController(text: _dbTally.title);
      _resetCounterController = TextEditingController(text: _dbTally.countReset.toString());
      _counterValueController = TextEditingController(text: _dbTally.count.toString());
    } else {
      _dbTally = DbTally.empty(created: DateTime.now(), lastUpdate: DateTime.now());
      _titleController = TextEditingController();
      _resetCounterController = TextEditingController();
      _counterValueController = TextEditingController(text: "0");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).tallyEditor),
      contentPadding: const EdgeInsets.all(16).copyWith(top: 0),
      titlePadding: const EdgeInsets.all(16),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUnfocus,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(S.of(context).addNameToCounter, textAlign: TextAlign.center),
              UserTextFormField(
                autoFocus: true,
                controller: _titleController,
                hintText: S.of(context).counterName,
                validator: (p0) => p0 == null || p0.isEmpty ? S.of(context).fieldIsRequired : null,
              ),
              Text(S.of(context).counterCircleSetToZero, textAlign: TextAlign.center),
              UserNumberFormField(
                controller: _resetCounterController,
                leadingIcon: MdiIcons.restore,
                hintText: S.of(context).circleEvery,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return S.of(context).fieldIsRequired;
                  }
                  final int? resetValue = int.tryParse(value);
                  if (resetValue == null || resetValue <= 0) {
                    return S.of(context).valueMustBeGreaterThanZero;
                  }
                  return null;
                },
              ),
              Text(S.of(context).tallyActualCounterDesc, textAlign: TextAlign.center),
              UserNumberFormField(
                controller: _counterValueController,
                leadingIcon: MdiIcons.counter,
                hintText: S.of(context).count,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return S.of(context).fieldIsRequired;
                  }
                  final int? countValue = int.tryParse(value);
                  if (countValue == null || countValue < 0) {
                    return S.of(context).valueMustBeGreaterThanZero;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        if (widget.dbTally != null)
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(S.of(context).delete),
            onPressed: () {
              Navigator.pop(
                context,
                EditorResult(action: EditorActionEnum.delete, value: _dbTally),
              );
            },
          )
        else
          const SizedBox(),
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
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final String title = _titleController.text.trim();
    final int? resetCounter = int.tryParse(_resetCounterController.text);
    final int? count = int.tryParse(_counterValueController.text);

    _dbTally = _dbTally.copyWith(title: title, countReset: resetCounter, count: count);

    if (_dbTally == widget.dbTally) {
      Navigator.pop(context);
      return;
    }

    Navigator.pop(
      context,
      EditorResult(
        action: widget.dbTally == null ? EditorActionEnum.add : EditorActionEnum.edit,
        value: _dbTally,
      ),
    );
  }
}
