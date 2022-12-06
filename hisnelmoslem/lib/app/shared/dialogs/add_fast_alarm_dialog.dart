import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:day_night_time_picker/lib/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/app/data/models/alarm.dart';
import 'package:hisnelmoslem/app/shared/dialogs/dialog_maker.dart';
import 'package:hisnelmoslem/app/shared/functions/handle_repeat_type.dart';
import 'package:hisnelmoslem/app/shared/functions/show_toast.dart';
import 'package:hisnelmoslem/core/utils/alarm_database_helper.dart';
import 'package:hisnelmoslem/core/utils/alarm_manager.dart';

import '../../../core/values/constant.dart';

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
  AddAlarmDialogState createState() => AddAlarmDialogState();
}

class AddAlarmDialogState extends State<AddAlarmDialog> {
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

  TextEditingController bodyController = TextEditingController(
      text: 'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ');

  String repeatType = 'يوميا';

  @override
  void dispose() {
    bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogMaker(
      height: 357,
      header: Text(
        "إضافة  تنبيه لـ",
        style: TextStyle(
          fontFamily: "Uthmanic",
          color: Theme.of(context).listTileTheme.textColor,
        ),
        textAlign: TextAlign.center,
      ),
      content: [
        Text(
          widget.dbAlarm.title,
          style: TextStyle(color: mainColor, fontSize: 20),
          textAlign: TextAlign.center,
        ),
        TextField(
          style: TextStyle(
            color: Theme.of(context).listTileTheme.textColor,
          ),
          textAlign: TextAlign.center,
          controller: bodyController,
          maxLength: 100,
          autofocus: true,
          decoration: const InputDecoration(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintText: "ضع رسالة لنفسك",
            contentPadding:
                EdgeInsets.only(left: 15, bottom: 5, top: 5, right: 15),
          ),
        ),
        Card(
          child: ListTile(
            title: Text(
              selectedHour == null
                  ? "اضغط لاختيار التوقيت"
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
                  onChangeDateTime: (DateTime dateTime) {},
                ),
              );
            },
          ),
        ),
        Card(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
            ),
            child: DropdownButton<String>(
              value: repeatType,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              iconSize: 30,
              underline: const SizedBox(),
              borderRadius: BorderRadius.circular(20),
              style: TextStyle(
                color: Theme.of(context).listTileTheme.textColor,
              ),
              dropdownColor: Theme.of(context).scaffoldBackgroundColor,
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
                  // alignment: Alignment.center,

                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: mainColor,
                    ),
                    // textAlign: TextAlign.center,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
      footer: Row(
        children: [
          Expanded(
            child: ListTile(
              title: const Text(
                "تم",
                textAlign: TextAlign.center,
              ),
              onTap: () {
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

                  alarmDatabaseHelper.addNewAlarm(dbAlarm: newAlarm);
                  alarmManager.alarmState(dbAlarm: newAlarm);
                  Navigator.pop(context, newAlarm);
                } else {
                  showToast(msg: "اختر وقتا للتذكير");
                }
              },
            ),
          ),
          Expanded(
            child: ListTile(
              title: Text(
                "close".tr,
                textAlign: TextAlign.center,
              ),
              onTap: () {
                Navigator.pop(
                  context,
                  DbAlarm(
                    id: widget.dbAlarm.id,
                    titleId: widget.dbAlarm.titleId,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
