import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';

class YesOrNoDialog extends StatelessWidget {
  final String msg;
  final String? details;

  const YesOrNoDialog({super.key, required this.msg, this.details});

  /// Resolves to `true` when confirmed, `false` when declined, `null` when dismissed.
  static Future<bool?> show(
    BuildContext context, {
    required String msg,
    String? details,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => YesOrNoDialog(msg: msg, details: details),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(msg),
      content: details == null ? null : Text(details ?? ""),
      actions: [
        TextButton(
          child: Text(S.of(context).no),
          onPressed: () {
            Navigator.pop<bool>(context, false);
          },
        ),
        FilledButton(
          child: Text(S.of(context).yes),
          onPressed: () {
            Navigator.pop<bool>(context, true);
          },
        ),
      ],
    );
  }
}
