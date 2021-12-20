import 'package:flutter/material.dart';
import 'package:hisnelmoslem/Providers/AppSettings.dart';
import 'package:hisnelmoslem/Screens/HRead.dart';
import 'package:hisnelmoslem/Screens/VRead.dart';
import 'package:hisnelmoslem/models/Zikr.dart';
import 'package:provider/provider.dart';

class ZikrCard extends StatelessWidget {
  final List<Zikr> zikrList;
  final int index;

  ZikrCard({@required this.index, @required this.zikrList});

  @override
  Widget build(BuildContext context) {
    final appSettings = Provider.of<AppSettingsNotifier>(context);
    String azkarReadMode = appSettings.getAzkarReadMode();
    return ListTile(
      // leading: Icon(Icons.bookmark_border),
      leading: zikrList[index].bookmark == "1"
          ? Icon(
              Icons.bookmark,
              color: Colors.blue.shade200,
            )
          : Icon(
              Icons.bookmark_border_outlined, /*color: Colors.blue.shade200,*/
            ),
      title: Text(zikrList[index].title),
      trailing: Text(zikrList[index].count),
      onTap: () {
        if (azkarReadMode == "Page") {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return HRead(zikr: zikrList[index]);
          }));
        } else if (azkarReadMode == "Card") {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return VRread(zikr: zikrList[index]);
          }));
        }
      },
    );
  }
}
