import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:day_night_time_picker/lib/constants.dart';
import 'package:flutter/material.dart';
import 'package:hisnelmoslem/AppManager/AlarmManager.dart';
import 'package:hisnelmoslem/Shared/Functions/HandleRepeatType.dart';
import 'package:hisnelmoslem/Shared/Functions/ShowToast.dart';
import 'package:hisnelmoslem/Shared/constant.dart';
import 'package:hisnelmoslem/Utils/alarm_database_helper.dart';
import 'package:hisnelmoslem/models/AlarmsDb/DbAlarm.dart';
import 'package:hisnelmoslem/models/AzkarDb/DbTitle.dart';

showFastAddAlarmDialog(
    {required BuildContext context, required DbTitle dbTitle}) {
  // show the dialog
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AddAlarmDialog(dbTitle: dbTitle);
    },
  );
}

class AddAlarmDialog extends StatefulWidget {
  final DbTitle dbTitle;

  const AddAlarmDialog({Key? key, required this.dbTitle}) : super(key: key);

  @override
  _AddAlarmDialogState createState() => _AddAlarmDialogState();
}

class _AddAlarmDialogState extends State<AddAlarmDialog> {
  TimeOfDay _time = TimeOfDay.now();

  bool iosStyle = true;
  int? selectedHour, selectedMinute;

  void onTimeChanged(TimeOfDay newTime) {
    setState(() {
      _time = newTime;
      selectedHour = newTime.hour;
      selectedMinute = newTime.minute;
    });
  }

  TextEditingController bodyController = TextEditingController();

  String repeatType = 'يوميا';

  @override
  void dispose() {
    bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "اضافة تنبيه لـ",
        style: TextStyle(fontFamily: "Uthmanic"),
      ),
      content: Container(
          height: 270,
          width: MediaQuery.of(context).size.width * .9,
          child: ScrollConfiguration(
              behavior: ScrollBehavior(),
              child: GlowingOverscrollIndicator(
                axisDirection: AxisDirection.down,
                color: Colors.black26,
                child: ListView(
                  children: [
                    Text(
                      widget.dbTitle.name,
                      style: TextStyle(color: MAINCOLOR, fontSize: 20),
                    ),
                    Divider(),
                    TextField(
                      style: TextStyle(decorationColor: MAINCOLOR),
                      textAlign: TextAlign.center,
                      controller: bodyController,
                      maxLength: 40,
                      autofocus: true,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintText: "ضع رسالة لنفسك",
                        contentPadding: EdgeInsets.only(
                            left: 15, bottom: 5, top: 5, right: 15),
                      ),
                    ),
                    Divider(),
                    InkWell(
                      onTap: () {},
                      child: ListTile(
                        title: Text(
                          selectedHour == null
                              ? "اختيار التوقيت"
                              : '$selectedHour : $selectedMinute',
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.ltr,
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            showPicker(
                              context: context,
                              value: _time,
                              onChange: onTimeChanged,
                              minuteInterval: MinuteInterval.ONE,
                              disableHour: false,
                              disableMinute: false,
                              minMinute: 0,
                              maxMinute: 59,
                              // Optional onChange to receive value as DateTime
                              onChangeDateTime: (DateTime dateTime) {
                                debugPrint("dateTime: " + dateTime.toString());
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    Divider(),
                    DropdownButton<String>(
                      value: repeatType,
                      icon: const Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      // style: const TextStyle(color: Colors.deepPurple),
                      // underline: Container(
                      //   height: 2,
                      //   color: Colors.deepPurpleAccent,
                      // ),
                      onChanged: (String? newValue) {
                        setState(() {
                          repeatType = newValue!;
                        });
                      },
                      items: <String>[
                        "يوميا",
                        "كل سبت",
                        "كل أحد",
                        "كل إثنين",
                        "كل ثلاثاء",
                        "كل أربعاء",
                        "كل خميس",
                        "كل جمعة",
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    )
                  ],
                ),
              ))),
      actions: [
        Padding(
          padding: EdgeInsets.only(left: 5),
          child: TextButton(
            style: TextButton.styleFrom(
              // minimumSize: Size(_width, _height),
              backgroundColor: Colors.white,
              padding: EdgeInsets.all(0),
            ),
            child: Text("تم"),
            onPressed: () {
              if (selectedHour != null) {
                DbAlarm newAlarm = DbAlarm(
                  id: widget.dbTitle.id,
                  title: widget.dbTitle.name,
                  body: bodyController.text,
                  hour: selectedHour!,
                  minute: selectedMinute!,
                  repeatType: HandleRepeatType()
                      .getNameToPutInDatabase(chosenValue: repeatType),
                  isActive: 1,
                );
                alarmDatabaseHelper.addNewAlarm(dbAlarm: newAlarm);
                alarmManager.alarmState(dbAlarm: newAlarm);
                Navigator.pop(context, true);
              } else {
                showToast(msg: "اختر وقتا للتذكير");
              }
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 5),
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              padding: EdgeInsets.all(0),
            ),
            child: Text("اغلاق"),
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
        )
      ],
    );
  }
}
