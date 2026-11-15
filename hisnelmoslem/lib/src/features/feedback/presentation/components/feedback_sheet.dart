import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/feedback/data/models/feedback_draft.dart';
import 'package:hisnelmoslem/src/features/feedback/data/models/feedback_type.dart';
import 'package:hisnelmoslem/src/features/feedback/presentation/components/shared_data_preview_dialog.dart';
import 'package:hisnelmoslem/src/features/feedback/presentation/controller/feedback_cubit.dart';

/// Asks the user for their message (and what to share) before the mail app opens.
///
/// Used for "Contact the developer", bug reports and misspelling reports.
class FeedbackSheet extends StatefulWidget {
  final FeedbackType initialType;
  final MisspellingContext? misspelling;

  const FeedbackSheet({
    super.key,
    this.initialType = FeedbackType.bug,
    this.misspelling,
  });

  /// Pass [misspelling] to report a wrong text: the type is then fixed and the user writes the
  /// correct text. Otherwise the user picks the type from a dropdown.
  static Future<void> show(
    BuildContext context, {
    FeedbackType initialType = FeedbackType.bug,
    MisspellingContext? misspelling,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => BlocProvider(
        create: (_) => sl<FeedbackCubit>(),
        child: FeedbackSheet(
          initialType: misspelling != null ? FeedbackType.misspelling : initialType,
          misspelling: misspelling,
        ),
      ),
    );
  }

  @override
  State<FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<FeedbackSheet> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  late FeedbackType _type = widget.initialType;
  bool _includeDeviceInfo = true;

  bool get _isMisspelling => widget.misspelling != null;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _showPreview() async {
    final preview = await context.read<FeedbackCubit>().preview();
    if (!mounted) return;
    await SharedDataPreviewDialog.show(context, preview);
  }

  Future<void> _send() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final cubit = context.read<FeedbackCubit>();
    final s = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final result = await cubit.submit(
      FeedbackDraft(
        type: _type,
        message: _messageController.text,
        includeDeviceInfo: _includeDeviceInfo,
        misspelling: widget.misspelling,
      ),
      s,
    );

    if (result == FeedbackSendResult.noMailApp) {
      await Clipboard.setData(ClipboardData(text: cubit.lastBody));
      messenger.showSnackBar(SnackBar(content: Text(s.feedbackMailFallback(kOrgEmail))));
    }
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final misspelling = widget.misspelling;
    final isSending = context.select((FeedbackCubit c) => c.state.isSending);

    return Padding(
      // Keeps the form above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 12,
                    children: [
                      Text(
                        _isMisspelling ? FeedbackType.misspelling.label(s) : s.feedbackTitle,
                        style: theme.textTheme.titleLarge,
                      ),
                      if (misspelling != null)
                        _MisspellingCard(misspelling: misspelling)
                      else
                        DropdownButtonFormField<FeedbackType>(
                          initialValue: _type,
                          decoration: InputDecoration(
                            labelText: s.feedbackTypeLabel,
                            border: const OutlineInputBorder(),
                          ),
                          items: [
                            for (final type in FeedbackType.selectable)
                              DropdownMenuItem(value: type, child: Text(type.label(s))),
                          ],
                          onChanged: (value) => setState(() => _type = value ?? _type),
                        ),
                      TextFormField(
                        controller: _messageController,
                        minLines: 4,
                        maxLines: 8,
                        maxLength: 3000,
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: _isMisspelling
                              ? s.feedbackCorrectionLabel
                              : s.feedbackMessageLabel,
                          hintText: _isMisspelling
                              ? s.feedbackCorrectionHint
                              : s.feedbackMessageHint,
                          alignLabelWithHint: true,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            (value ?? '').trim().isEmpty ? s.feedbackMessageRequired : null,
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        value: _includeDeviceInfo,
                        onChanged: (value) => setState(() => _includeDeviceInfo = value ?? false),
                        title: Text(s.feedbackShareDeviceInfo),
                        subtitle: Text(s.feedbackShareDeviceInfoDesc),
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton.icon(
                          onPressed: _showPreview,
                          icon: const Icon(Icons.visibility_outlined),
                          label: Text(s.feedbackWhatShared),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Outside the scroll area, so it stays visible above the keyboard.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isSending ? null : _send,
                  icon: isSending
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(s.feedbackSend),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The text being reported, so the user sees what the report is about.
class _MisspellingCard extends StatelessWidget {
  final MisspellingContext misspelling;
  const _MisspellingCard({required this.misspelling});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final heading = misspelling.isFakeHadith
        ? '${s.fakeHadith} · ${s.cardIndex} ${misspelling.index}'
        : '${misspelling.title} · ${s.zikrIndex} ${misspelling.index}';

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            Text(heading, style: theme.textTheme.labelLarge),
            Text(s.feedbackCurrentText, style: theme.textTheme.labelSmall),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 140),
              child: SingleChildScrollView(child: Text(misspelling.currentText)),
            ),
          ],
        ),
      ),
    );
  }
}
