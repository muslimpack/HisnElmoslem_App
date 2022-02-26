import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:day_night_time_picker/lib/constants.dart';
import 'package:flutter/material.dart';
import 'package:hisnelmoslem/Utils/alarm_database_helper.dart';
import 'package:hisnelmoslem/models/alarm.dart';
import 'package:hisnelmoslem/shared/functions/handle_repeat_type.dart';
import 'package:hisnelmoslem/shared/functions/show_toast.dart';
import 'package:hisnelmoslem/utils/alarm_manager.dart';

import '../constants/constant.dart';

Future<DbAlarm> showFastEditAlarmDialog(
    {required BuildContext context, required DbAlarm dbAlarm}) async {
  // show the dialog
  return await showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AddAlarmDialog(dbAlarm: dbAlarm);
    },
  );
}

class AddAlarmDialog extends StatefulWidget {
  final DbAlarm dbAlarm;

  const AddAlarmDialog({Key? key, required this.dbAlarm}) : super(key: key);

  @override
  _AddAlarmDialogState createState() => _AddAlarmDialogState();
}

class _AddAlarmDialogState extends State<AddAlarmDialog> {
  late TimeOfDay _time = TimeOfDay.now();

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

  late String repeatType;

  @override
  void initState() {
    super.initState();
    _time = TimeOfDay.now()
        .replacing(hour: widget.dbAlarm.hour, minute: widget.dbAlarm.minute);

    bodyController = TextEditingController(text: widget.dbAlarm.body);
    repeatType = HandleRepeatType()
        .getNameToUser(chosenValue: widget.dbAlarm.repeatType);
    selectedHour = widget.dbAlarm.hour;
    selectedMinute = widget.dbAlarm.minute;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "تعديل تنبيه",
        style: TextStyle(fontFamily: "Uthmanic"),
      ),
      content: Container(
          height: 270,
          width: MediaQuery.of(context).size.width * .9,
          child: ScrollConfiguration(
              behavior: ScrollBehavior(),
              child: GlowingOverscrollIndicator(
                axisDirection: AxisDirection.down,
                color: black26,
                child: ListView(
                  children: [
                    Text(
                      widget.dbAlarm.title,
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
              // backgroundColor: white,
              padding: EdgeInsets.all(0),
            ),
            child: Text("تم"),
            onPressed: () {
              setState(() {
                if (selectedHour != null) {
                  DbAlarm updateAlarm = DbAlarm(
                    titleId: widget.dbAlarm.id,
                    id: widget.dbAlarm.id,
                    title: widget.dbAlarm.title,
                    body: bodyController.text,
                    hour: selectedHour!,
                    hasAlarmInside: true,
                    minute: selectedMinute!,
                    repeatType: HandleRepeatType()
                        .getNameToPutInDatabase(chosenValue: repeatType),
                    isActive: widget.dbAlarm.isActive,
                  );

                  alarmDatabaseHelper.updateAlarmInfo(dbAlarm: updateAlarm);
                  alarmManager.alarmState(dbAlarm: updateAlarm);
                  Navigator.pop(context, updateAlarm);
                } else {
                  showToast(msg: "اختر وقتا للتذكير");
                }
              });
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 5),
          child: TextButton(
            style: TextButton.styleFrom(
              // minimumSize: Size(_width, _height),
              // backgroundColor: white,
              padding: EdgeInsets.all(0),
            ),
            child: Text("اغلاق"),
            onPressed: () {
              widget.dbAlarm.hasAlarmInside = true;
              Navigator.pop(context, widget.dbAlarm);
            },
          ),
        )
      ],
    );
  }
}
