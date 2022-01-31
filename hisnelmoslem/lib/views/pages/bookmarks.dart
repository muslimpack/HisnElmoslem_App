import 'package:flutter/material.dart';
import 'package:hisnelmoslem/Shared/Widgets/Loading.dart';
import 'package:hisnelmoslem/Shared/constant.dart';
import 'package:hisnelmoslem/models/alarm.dart';
import 'package:hisnelmoslem/models/zikr_title.dart';
import 'package:hisnelmoslem/shared/cards/zikr_card.dart';

class AzkarBookmarks extends StatefulWidget {
  final List<DbTitle> titles;
  final List<DbAlarm> alarms;
  AzkarBookmarks({required this.titles, required this.alarms});
  @override
  _AzkarBookmarksState createState() => _AzkarBookmarksState();
}

class _AzkarBookmarksState extends State<AzkarBookmarks> {
  final ScrollController _controllerOne = ScrollController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controllerOne.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Loading()
        : Scaffold(
            body: RefreshIndicator(
              color: MAINCOLOR,
              onRefresh: () async {},
              child: Scrollbar(
                controller: _controllerOne,
                isAlwaysShown: false,
                child: new ListView.builder(
                  padding: EdgeInsets.only(top: 10),
                  itemBuilder: (context, index) {
                    return ZikrCard(
                      fehrsTitle: widget.titles[index],
                      alarm: DbAlarm(id: index),
                    );
                  },
                  itemCount: widget.titles.length,
                ),
              ),
            ),
          );
  }
}
