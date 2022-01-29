import 'package:flutter/material.dart';
import 'package:hisnelmoslem/Shared/constant.dart';
import 'package:hisnelmoslem/Utils/azkar_database_helper.dart';
import 'package:hisnelmoslem/models/zikr_title.dart';
import 'package:hisnelmoslem/providers/app_settings.dart';
import 'package:hisnelmoslem/shared/dialogs/add_fast_alarm_dialog.dart';
import 'package:hisnelmoslem/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/views/screens/azkar_read_card.dart';
import 'package:hisnelmoslem/views/screens/azkar_read_page.dart';
import 'package:provider/provider.dart';

class ZikrCard extends StatefulWidget {
  final List<DbTitle> fehrsTitle;
  final int index;

  ZikrCard({required this.index, required this.fehrsTitle});

  @override
  _ZikrCardState createState() => _ZikrCardState();
}

class _ZikrCardState extends State<ZikrCard> {
  @override
  Widget build(BuildContext context) {
    final appSettings = Provider.of<AppSettingsNotifier>(context);

    return ListTile(
      leading: widget.fehrsTitle[widget.index].favourite == 1
          ? IconButton(
              icon: Icon(
                Icons.bookmark,
                color: Colors.blue.shade200,
              ),
              onPressed: () {
                setState(() {
                  azkarDatabaseHelper.deleteFromFavourite(
                      dbTitle: widget.fehrsTitle[widget.index]);
                  widget.fehrsTitle[widget.index].favourite = 0;
                });
              })
          : IconButton(
              icon: Icon(Icons.bookmark_border_outlined),
              onPressed: () {
                setState(() {
                  // azkarDatabaseHelper.deleteFromFavourite(
                  //     dbTitle: widget.fehrsTitle[widget.index]);
                  azkarDatabaseHelper.addToFavourite(
                      dbTitle: widget.fehrsTitle[widget.index]);
                  widget.fehrsTitle[widget.index].favourite = 1;
                });
              }),
      trailing: IconButton(
          icon: widget.fehrsTitle[widget.index].alarm == 0
              ? Icon(Icons.alarm_add_rounded)
              : Icon(
                  Icons.alarm,
                  color: MAINCOLOR,
                ),
          onPressed: () {
            setState(() {
              showFastAddAlarmDialog(
                  context: context, dbTitle: widget.fehrsTitle[widget.index]);
            });
          }),
      title: Text(widget.fehrsTitle[widget.index].name,
          style: TextStyle(fontFamily: "Uthmanic")),
      // trailing: Text(zikrList[index]),
      onTap: () {
        String azkarReadMode = appSettings.getAzkarReadMode();
        if (azkarReadMode == "Page") {
          transitionAnimation.circleReval(
              context: context,
              goToPage:
                  AzkarReadPage(index: widget.fehrsTitle[widget.index].id));
        } else if (azkarReadMode == "Card") {
          transitionAnimation.circleReval(
              context: context,
              goToPage:
                  AzkarReadCard(index: widget.fehrsTitle[widget.index].id));
        }
      },
    );
  }
}
