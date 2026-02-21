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
  return showModalBottomSheet<EditorResult<DbTally>?>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => SafeArea(child: _TallyEditor(dbTally: dbTally)),
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

  bool get _isEditing => widget.dbTally != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
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
  void dispose() {
    _titleController.dispose();
    _resetCounterController.dispose();
    _counterValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUnfocus,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withAlpha((0.3 * 255).round()),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // Header
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      _isEditing ? Icons.edit_outlined : Icons.add,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    S.of(context).tallyEditor,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Name field
              _SectionLabel(label: S.of(context).addNameToCounter),
              const SizedBox(height: 8),
              UserTextFormField(
                autoFocus: true,
                controller: _titleController,
                hintText: S.of(context).counterName,
                validator: (p0) => p0 == null || p0.isEmpty ? S.of(context).fieldIsRequired : null,
              ),

              const SizedBox(height: 20),

              // Reset every field
              _SectionLabel(label: S.of(context).counterCircleSetToZero),
              const SizedBox(height: 8),
              UserNumberFormField(
                controller: _resetCounterController,
                leadingIcon: MdiIcons.restore,
                hintText: S.of(context).circleEvery,
                validator: (value) {
                  if (value == null || value.isEmpty) return S.of(context).fieldIsRequired;
                  final int? v = int.tryParse(value);
                  if (v == null || v <= 0) return S.of(context).valueMustBeGreaterThanZero;
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Count field
              _SectionLabel(label: S.of(context).tallyActualCounterDesc),
              const SizedBox(height: 8),
              UserNumberFormField(
                controller: _counterValueController,
                leadingIcon: MdiIcons.counter,
                hintText: S.of(context).count,
                validator: (value) {
                  if (value == null || value.isEmpty) return S.of(context).fieldIsRequired;
                  final int? v = int.tryParse(value);
                  if (v == null || v < 0) return S.of(context).valueMustBeGreaterThanZero;
                  return null;
                },
              ),

              const SizedBox(height: 28),

              // Actions
              Row(
                children: [
                  if (_isEditing) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.error,
                          side: BorderSide(color: colorScheme.error),
                        ),
                        icon: const Icon(Icons.delete_outline),
                        label: Text(S.of(context).delete),
                        onPressed: () => Navigator.pop(
                          context,
                          EditorResult(action: EditorActionEnum.delete, value: _dbTally),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: onSubmit,
                      icon: Icon(_isEditing ? Icons.check : Icons.add),
                      label: Text(_isEditing ? S.of(context).edit : S.of(context).add),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

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
        action: _isEditing ? EditorActionEnum.edit : EditorActionEnum.add,
        value: _dbTally,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
