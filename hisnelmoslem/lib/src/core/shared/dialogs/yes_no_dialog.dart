import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';

class YesOrNoDialog extends StatelessWidget {
  final String msg;
  final Function() onYes;

  const YesOrNoDialog({super.key, required this.onYes, required this.msg});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
        margin: EdgeInsets.zero,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                S.of(context).are_you_sure,
                style: TextStyle(fontSize: 20, color: mainColor),
              ),
            ),
            const Divider(),
            Text(
              msg,
              style: const TextStyle(fontSize: 15),
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text(
                      S.of(context).yes,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: mainColor),
                    ),
                    onTap: () {
                      onYes();
                      Navigator.pop<bool>(context, true);
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text(
                      S.of(context).no,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: mainColor),
                    ),
                    onTap: () {
                      Navigator.pop<bool>(context, false);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
