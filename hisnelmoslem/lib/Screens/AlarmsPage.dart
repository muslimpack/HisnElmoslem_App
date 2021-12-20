import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hisnelmoslem/AppManager/AlarmManager.dart';
import 'package:hisnelmoslem/Shared/Cards/AlarmCard.dart';
import 'package:hisnelmoslem/Shared/Dialogs/EditFastAlarmDialog.dart';
import 'package:hisnelmoslem/Shared/Functions/HandleRepeatType.dart';
import 'package:hisnelmoslem/Shared/Widgets/Loading.dart';
import 'package:hisnelmoslem/Shared/constant.dart';
import 'package:hisnelmoslem/Utils/alarm_database_helper.dart';
import 'package:hisnelmoslem/models/AlarmsDb/DbAlarm.dart';

class AlarmsPages extends StatefulWidget {
  const AlarmsPages({Key? key}) : super(key: key);

  @override
  _AlarmsPagesState createState() => _AlarmsPagesState();
}

class _AlarmsPagesState extends State<AlarmsPages> {
  final ScrollController _controllerOne = ScrollController();

  List<DbAlarm> alarms = <DbAlarm>[];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    getAllListsReady();
  }

  getAllListsReady() async {
    alarms = <DbAlarm>[];
    setState(() {
      isLoading = true;
    });

    await alarmDatabaseHelper.getAlarms().then((value) {
      setState(() {
        alarms = value;
      });
    });

    //QuranPageLists

    print(alarms.length);
    setState(() {
      isLoading = false;
    });
  }

  Widget alarmCard({required int index}) {
    bool isActive = false;
    if (alarms[index].isActive == 1) {
      isActive = true;
    } else {
      isActive = false;
    }
    return new Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: .2,
      actions: [
        RoundButton(
          widget: Icon(Icons.delete),
          color: Colors.red.shade300,
          onTap: () {
            setState(() {
              alarmDatabaseHelper.deleteAlarm(dbAlarm: alarms[index]);
              alarms.removeAt(index);
            });
          },
        ),
      ],
      secondaryActions: [
        RoundButton(
          widget: Icon(Icons.edit),
          color: Colors.green.shade300,
          onTap: () {
            setState(() {
              showFastEditAlarmDialog(
                context: context,
                dbAlarm: alarms[index],
              );
            });
          },
        ),
      ],
      child: Column(
        children: [
          SwitchListTile(
            title: ListTile(
              contentPadding: EdgeInsets.all(0),
              // leading: Icon(Icons.bookmark_border),
              leading: Icon(
                Icons.alarm,
              ),
              subtitle: Wrap(
                children: [
                  RoundTagCard(
                    name: alarms[index].body,
                    color: Colors.green.shade300,
                  ),
                  RoundTagCard(
                    name: '⌚ ${alarms[index].hour} : ${alarms[index].minute}',
                    color: Colors.blue.shade300,
                  ),
                  RoundTagCard(
                    name: HandleRepeatType()
                        .getNameToUser(chosenValue: alarms[index].repeatType),
                    color: Colors.orange.shade300,
                  ),
                ],
              ),
              isThreeLine: true,
              title: Text(alarms[index].title),
            ),
            activeColor: MAINCOLOR,
            value: isActive,
            onChanged: (value) {
              setState(() {
                //Update database
                DbAlarm updateAlarm = alarms[index];
                value ? updateAlarm.isActive = 1 : updateAlarm.isActive = 0;
                alarmDatabaseHelper.updateAlarmInfo(dbAlarm: updateAlarm);
                // update view
                isActive = value;
                //
                alarmManager.alarmState(dbAlarm: updateAlarm);
              });
            },
          ),
          // Divider(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("إدارة تنبيهات الأذكار",
              style: TextStyle(fontFamily: "Uthmanic")),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
        ),
        body: isLoading
            ? Loading()
            : RefreshIndicator(
                color: MAINCOLOR,
                onRefresh: () async {
                  getAllListsReady();
                },
                child: Scrollbar(
                  controller: _controllerOne,
                  isAlwaysShown: false,
                  child: new ScrollConfiguration(
                    behavior: ScrollBehavior(),
                    child: GlowingOverscrollIndicator(
                      axisDirection: AxisDirection.down,
                      color: Colors.black26,
                      child: new ListView.builder(
                        padding: EdgeInsets.only(top: 10),
                        itemBuilder: (context, index) {
                          return alarmCard(index: index);
                        },
                        itemCount: alarms.length,
                      ),
                    ),
                  ),
                ),
              ));
  }
}
