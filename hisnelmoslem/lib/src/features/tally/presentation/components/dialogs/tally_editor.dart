import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/models/editor_result.dart';
import 'package:hisnelmoslem/src/core/shared/custom_inputs/number_field.dart';
import 'package:hisnelmoslem/src/core/shared/custom_inputs/text_field.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/data/services/custom_audio_storage.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/components/record_audio_sheet.dart';
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

  /// Recordings made while this sheet is open. Only the one the counter ends up
  /// with is kept, and only if the sheet is saved.
  final Set<String> _createdFiles = {};
  bool _saved = false;

  bool get _isEditing => widget.dbTally != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _dbTally = widget.dbTally!;
      _titleController = TextEditingController(text: _dbTally.title);
      _resetCounterController = TextEditingController(
        text: _dbTally.countReset.toString(),
      );
      _counterValueController = TextEditingController(
        text: _dbTally.count.toString(),
      );
    } else {
      _dbTally = DbTally.empty(
        created: DateTime.now(),
        lastUpdate: DateTime.now(),
      );
      _titleController = TextEditingController();
      _resetCounterController = TextEditingController(text: "33");
      _counterValueController = TextEditingController(text: "0");
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _resetCounterController.dispose();
    _counterValueController.dispose();

    final storage = sl<CustomAudioStorage>();
    for (final file in _createdFiles) {
      storage.unpin(file);
      if (!_saved || file != _dbTally.audioFile) storage.delete(file);
    }
    super.dispose();
  }

  Future<void> _recordVoice() async {
    final result = await RecordAudioSheet.show(
      context,
      zikrText: _titleController.text.trim(),
      existingFile: _dbTally.hasAudio ? _dbTally.audioFile : null,
    );
    if (result == null || !mounted) return;

    final storage = sl<CustomAudioStorage>();
    final previous = _dbTally.audioFile;
    final fresh = result.fileName ?? "";

    if (fresh.isNotEmpty) {
      // Protected from clean-ups until the sheet is closed.
      storage.pin(fresh);
      _createdFiles.add(fresh);
    }
    if (previous.isNotEmpty && previous != fresh && _createdFiles.remove(previous)) {
      // A take of this same session that was replaced: nothing refers to it.
      storage.unpin(previous);
      await storage.delete(previous);
    }
    setState(() => _dbTally = _dbTally.copyWith(audioFile: fresh));
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
                    color: colorScheme.onSurfaceVariant.withAlpha(
                      (0.3 * 255).round(),
                    ),
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
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
                textInputAction: TextInputAction.next,
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
                textInputAction: TextInputAction.next,
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
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.isEmpty) return S.of(context).fieldIsRequired;
                  final int? v = int.tryParse(value);
                  if (v == null || v < 0) return S.of(context).valueMustBeGreaterThanZero;
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Voice
              _SectionLabel(label: S.of(context).tallyVoiceSection),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: Icon(_dbTally.hasAudio ? Icons.mic_rounded : Icons.mic_none_rounded),
                label: Text(
                  _dbTally.hasAudio ? S.of(context).recordMyVoiceBadge : S.of(context).recordVoice,
                ),
                onPressed: _recordVoice,
              ),
              const SizedBox(height: 4),
              Text(
                S.of(context).tallyVoiceHint,
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
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
                          EditorResult(
                            action: EditorActionEnum.delete,
                            value: _dbTally,
                          ),
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
                      label: Text(
                        _isEditing ? S.of(context).edit : S.of(context).add,
                      ),
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

    _dbTally = _dbTally.copyWith(
      title: title,
      countReset: resetCounter,
      count: count,
    );

    if (_dbTally == widget.dbTally) {
      Navigator.pop(context);
      return;
    }

    _saved = true;

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
