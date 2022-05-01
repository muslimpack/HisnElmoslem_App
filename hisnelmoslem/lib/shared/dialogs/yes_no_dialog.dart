import 'package:hisnelmoslem/shared/constants/constant.dart';
import 'package:flutter/material.dart';

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
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text("تنويه",
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
                    title: const Text(
                      "نعم",
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
                  title: const Text(
                    "لا",
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
