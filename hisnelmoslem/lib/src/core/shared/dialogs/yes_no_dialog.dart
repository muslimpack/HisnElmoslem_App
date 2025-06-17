import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';

class YesOrNoDialog extends StatelessWidget {
  final String msg;
  final String? details;

  const YesOrNoDialog({super.key, required this.msg, this.details});

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
