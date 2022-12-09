import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/core/values/constant.dart';

class YesOrNoDialog extends StatelessWidget {
  final String msg;
  final Function onYes;

  const YesOrNoDialog({Key? key, required this.onYes, required this.msg})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
        margin: const EdgeInsets.all(0.0),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text("are you sure?".tr,
                  style: TextStyle(fontSize: 25, color: mainColor)),
            ),
            const Divider(),
            Text(
              msg,
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text(
                      "yes".tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, color: mainColor),
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
                    style: TextStyle(fontSize: 20, color: mainColor),
                  ),
                  onTap: () {
                    Navigator.pop<bool>(context, false);
                  },
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
