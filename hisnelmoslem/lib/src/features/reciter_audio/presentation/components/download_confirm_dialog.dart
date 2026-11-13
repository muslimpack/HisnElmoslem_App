import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/byte_format.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/download_plan.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/components/reciter_name.dart';

/// Asks before a download starts, with the number of files and the size the server reported.
class DownloadConfirmDialog extends StatelessWidget {
  final DownloadPlan plan;
  const DownloadConfirmDialog({super.key, required this.plan});

  /// True when the user agrees to download.
  static Future<bool> show(BuildContext context, {required DownloadPlan plan}) async {
    final agreed = await showDialog<bool>(
      context: context,
      builder: (_) => DownloadConfirmDialog(plan: plan),
    );
    return agreed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final count = plan.pendingUrls.length;
    // A size is only shown when the server told us every file's size.
    final body = plan.unknownSizes == 0
        ? s.audioDownloadConfirmBody(count, formatBytes(plan.pendingBytes))
        : s.audioDownloadConfirmBodyNoSize(count);

    return AlertDialog(
      title: Text(s.audioDownloadConfirmTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(plan.reciter.localizedName(context), style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Text(body),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(s.cancel)),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(s.audioDownloadAll),
        ),
      ],
    );
  }
}
