import 'package:flutter/material.dart';
import 'package:hisnelmoslem/Shared/Widgets/Loading.dart';
import 'package:hisnelmoslem/models/alarm.dart';
import 'package:hisnelmoslem/models/zikr_title.dart';
import 'package:hisnelmoslem/shared/cards/zikr_card.dart';

class AzkarFehrs extends StatefulWidget {
  final List<DbTitle> titles;
  final List<DbAlarm> alarms;
  const AzkarFehrs({
    Key? key,
    required this.titles,
    required this.alarms,
  }) : super(key: key);

  @override
  _AzkarFehrsState createState() => _AzkarFehrsState();
}

class _AzkarFehrsState extends State<AzkarFehrs> {
  final ScrollController _controllerOne = ScrollController();

  bool isLoading = false;

  @override
  void dispose() {
    _controllerOne.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Loading()
        : Scaffold(
            body: Scrollbar(
              controller: _controllerOne,
              isAlwaysShown: false,
              child: new ListView.builder(
                padding: EdgeInsets.only(top: 10),
                itemBuilder: (context, index) {
                  DbAlarm tempAlarm = DbAlarm(id: index);
                  for (var item in widget.alarms) {
                    // debugPrint(item.toString());
                    if (item.id == index) {
                      tempAlarm = item;
                    }
                  }
                  return ZikrCard(
                      fehrsTitle: widget.titles[index], alarm: tempAlarm);
                },
                itemCount: widget.titles.length,
              ),
            ),
          );
  }
}
