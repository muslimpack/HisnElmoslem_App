import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/l10n.dart';

class YesOrNoDialog extends StatelessWidget {
  final String msg;

  const YesOrNoDialog({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        S.of(context).areYouSure,
      ),
      content: Text(
        msg,
      ),
      actions: [
        TextButton(
          child: Text(
            S.of(context).no,
          ),
          onPressed: () {
            Navigator.pop<bool>(context, false);
          },
        ),
        TextButton(
          child: Text(
            S.of(context).yes,
          ),
          onPressed: () {
            Navigator.pop<bool>(context, true);
          },
        ),
      ],
    );
  }
}
