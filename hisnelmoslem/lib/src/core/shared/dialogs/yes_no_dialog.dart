import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
                "are you sure?".tr,
                style: const TextStyle(fontSize: 20),
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
                      "yes".tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15),
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
                      "no".tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15),
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
