import 'package:flutter/material.dart';
import 'package:hisnelmoslem/Shared/constant.dart';
import 'package:hisnelmoslem/Utils/azkar_database_helper.dart';
import 'package:hisnelmoslem/models/alarm.dart';
import 'package:hisnelmoslem/models/zikr_title.dart';
import 'package:hisnelmoslem/providers/app_settings.dart';
import 'package:hisnelmoslem/shared/dialogs/add_fast_alarm_dialog.dart';
import 'package:hisnelmoslem/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/views/screens/azkar_read_card.dart';
import 'package:hisnelmoslem/views/screens/azkar_read_page.dart';
import 'package:provider/provider.dart';

class ZikrCard extends StatefulWidget {
  final DbTitle fehrsTitle;
  final DbAlarm alarm;
  ZikrCard({required this.fehrsTitle, required this.alarm});

  @override
  _ZikrCardState createState() => _ZikrCardState();
}

class _ZikrCardState extends State<ZikrCard> {
  late DbTitle fehrsTitle;
  late DbAlarm dbAlarm;
  @override
  void initState() {
    fehrsTitle = widget.fehrsTitle;
    dbAlarm = widget.alarm;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appSettings = Provider.of<AppSettingsNotifier>(context);

    return ListTile(
      leading: fehrsTitle.favourite == 1
          ? IconButton(
              icon: Icon(
                Icons.bookmark,
                color: Colors.blue.shade200,
              ),
              onPressed: () {
                setState(() {
                  azkarDatabaseHelper.deleteFromFavourite(dbTitle: fehrsTitle);
                  fehrsTitle.favourite = 0;
                });
              })
          : IconButton(
              icon: Icon(Icons.bookmark_border_outlined),
              onPressed: () {
                setState(() {
                  // azkarDatabaseHelper.deleteFromFavourite(
                  //     dbTitle: fehrsTitle);
                  azkarDatabaseHelper.addToFavourite(dbTitle: fehrsTitle);
                  fehrsTitle.favourite = 1;
                });
              }),
      trailing: IconButton(
          icon: true
              ? Icon(Icons.alarm_add_rounded)
              : Icon(
                  Icons.alarm,
                  color: MAINCOLOR,
                ),
          onPressed: () {
            dbAlarm.title = fehrsTitle.name;
            showFastAddAlarmDialog(context: context, dbAlarm: dbAlarm)
                .then((value) {
              setState(() {
                dbAlarm = value;
              });
              debugPrint(value.toString());
            });
          }),
      title: Text(fehrsTitle.name, style: TextStyle(fontFamily: "Uthmanic")),
      // trailing: Text(zikrList[index]),
      onTap: () {
        String azkarReadMode = appSettings.getAzkarReadMode();
        if (azkarReadMode == "Page") {
          transitionAnimation.circleReval(
              context: context, goToPage: AzkarReadPage(index: fehrsTitle.id));
        } else if (azkarReadMode == "Card") {
          transitionAnimation.circleReval(
              context: context, goToPage: AzkarReadCard(index: fehrsTitle.id));
        }
      },
    );
  }
}
