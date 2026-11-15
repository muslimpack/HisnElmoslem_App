import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/feedback/presentation/controller/feedback_cubit.dart';

/// Shows exactly what is added to the email when the user agrees to share device data.
class SharedDataPreviewDialog extends StatelessWidget {
  final FeedbackPreview preview;
  const SharedDataPreviewDialog({super.key, required this.preview});

  static Future<void> show(BuildContext context, FeedbackPreview preview) {
    return showDialog<void>(
      context: context,
      builder: (_) => SharedDataPreviewDialog(preview: preview),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(s.feedbackSharedPreviewTitle),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              Text(s.feedbackDeviceInfoSection, style: theme.textTheme.titleSmall),
              for (final entry in preview.deviceInfo.entries)
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${entry.key}: ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: entry.value),
                    ],
                  ),
                  textDirection: TextDirection.ltr,
                ),
              const SizedBox(height: 8),
              Text(s.feedbackRecentErrors, style: theme.textTheme.titleSmall),
              if (preview.errorsText.isEmpty)
                Text(s.feedbackNoErrors)
              else
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: SelectableText(
                    preview.errorsText,
                    style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(s.close)),
      ],
    );
  }
}
