import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:day_night_time_picker/lib/constants.dart';
import 'package:flutter/material.dart';
import 'package:hisnelmoslem/utils/alarm_database_helper.dart';
import 'package:hisnelmoslem/models/alarm.dart';
import 'package:hisnelmoslem/shared/functions/handle_repeat_type.dart';
import 'package:hisnelmoslem/shared/functions/show_toast.dart';
import 'package:hisnelmoslem/utils/alarm_manager.dart';

import '../constants/constant.dart';

Future<dynamic> showFastAddAlarmDialog(
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
  TimeOfDay _time = TimeOfDay.now();

  bool iosStyle = true;
  int? selectedHour, selectedMinute;

  @override
  void initState() {
    super.initState();
    //
    debugPrint("widget.dbAlarm.titleId: " + widget.dbAlarm.titleId.toString());
  }

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
      title: const Text(
        "اضافة تنبيه لـ",
        style: TextStyle(fontFamily: "Uthmanic"),
      ),
      content: SizedBox(
          height: 270,
          width: MediaQuery.of(context).size.width * .9,
          child: ScrollConfiguration(
              behavior: const ScrollBehavior(),
              child: GlowingOverscrollIndicator(
                axisDirection: AxisDirection.down,
                color: black26,
                child: ListView(
                  children: [
                    Text(
                      widget.dbAlarm.title,
                      style: const TextStyle(color: mainColor, fontSize: 20),
                    ),
                    const Divider(),
                    TextField(
                      style: const TextStyle(decorationColor: mainColor),
                      textAlign: TextAlign.center,
                      controller: bodyController,
                      maxLength: 40,
                      autofocus: true,
                      decoration: const InputDecoration(
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
                    const Divider(),
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
                    const Divider(),
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
          padding: const EdgeInsets.only(left: 5),
          child: TextButton(
            style: TextButton.styleFrom(
              // minimumSize: Size(_width, _height),
              // backgroundColor: white,
              padding: const EdgeInsets.all(0),
            ),
            child: const Text("تم"),
            onPressed: () {
              if (selectedHour != null) {
                DbAlarm newAlarm = DbAlarm(
                  id: widget.dbAlarm.id,
                  titleId: widget.dbAlarm.titleId,
                  title: widget.dbAlarm.title,
                  body: bodyController.text,
                  hour: selectedHour!,
                  minute: selectedMinute!,
                  hasAlarmInside: true,
                  repeatType: HandleRepeatType()
                      .getNameToPutInDatabase(chosenValue: repeatType),
                  isActive: true,
                );

                debugPrint("widget.dbAlarm.titleId: " +
                    widget.dbAlarm.titleId.toString());

                debugPrint(
                    "newAlarm: $newAlarm" + widget.dbAlarm.titleId.toString());
                alarmDatabaseHelper.addNewAlarm(dbAlarm: newAlarm);
                alarmManager.alarmState(dbAlarm: newAlarm);
                Navigator.pop(context, newAlarm);
              } else {
                showToast(msg: "اختر وقتا للتذكير");
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: TextButton(
            style: TextButton.styleFrom(
              // backgroundColor: white,
              padding: const EdgeInsets.all(0),
            ),
            child: const Text("اغلاق"),
            onPressed: () {
              Navigator.pop(
                  context,
                  DbAlarm(
                      id: widget.dbAlarm.id, titleId: widget.dbAlarm.titleId));
            },
          ),
        )
      ],
    );
  }
}
