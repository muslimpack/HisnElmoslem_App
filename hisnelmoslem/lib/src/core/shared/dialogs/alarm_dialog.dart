import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/functions/handle_repeat_type.dart';
import 'package:hisnelmoslem/src/core/functions/show_toast.dart';
import 'package:hisnelmoslem/src/core/shared/dialogs/dialog_maker.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/alarm.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/alarm_manager.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/repository/alarm_database_helper.dart';

Future<dynamic> showFastAlarmDialog({
  required BuildContext context,
  required DbAlarm dbAlarm,
  required bool isToEdit,
}) async {
  // show the dialog
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AddAlarmDialog(
        dbAlarm: dbAlarm,
        isToEdit: isToEdit,
      );
    },
  );
}

class AddAlarmDialog extends StatefulWidget {
  final DbAlarm dbAlarm;
  final bool isToEdit;

  const AddAlarmDialog({
    super.key,
    required this.dbAlarm,
    required this.isToEdit,
  });

  @override
  AddAlarmDialogState createState() => AddAlarmDialogState();
}

class AddAlarmDialogState extends State<AddAlarmDialog> {
  late TimeOfDay _time = TimeOfDay.now();

  bool iosStyle = true;
  int? selectedHour;
  int? selectedMinute;

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
    if (widget.isToEdit) {
      _time = TimeOfDay.now()
          .replacing(hour: widget.dbAlarm.hour, minute: widget.dbAlarm.minute);

      bodyController = TextEditingController(text: widget.dbAlarm.body);
      repeatType = HandleRepeatType()
          .getNameToUser(chosenValue: widget.dbAlarm.repeatType);
      selectedHour = widget.dbAlarm.hour;
      selectedMinute = widget.dbAlarm.minute;
    } else {
      bodyController = TextEditingController(
        text: 'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
      );
      repeatType = "daily".tr;
    }
  }

  @override
  void dispose() {
    bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogMaker(
      height: 380,
      header: Text(
        () {
          if (widget.isToEdit) {
            return "edit reminder".tr;
          } else {
            return "add reminder".tr;
          }
        }(),
        style: const TextStyle(
          fontSize: 25,
        ),
        textAlign: TextAlign.center,
      ),
      content: [
        Text(
          widget.dbAlarm.title,
          style: const TextStyle(fontSize: 20),
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
          decoration: InputDecoration(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintText: "set message for you".tr,
            contentPadding:
                const EdgeInsets.only(left: 15, bottom: 5, top: 5, right: 15),
          ),
        ),
        Card(
          clipBehavior: Clip.hardEdge,
          child: ListTile(
            leading: const Icon(Icons.alarm),
            title: Text(
              selectedHour == null
                  ? "click to choose time".tr
                  : '$selectedHour : $selectedMinute',
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
            ),
            onTap: () {
              Navigator.of(context).push(
                showPicker(
                  context: context,
                  value: Time(hour: _time.hour, minute: _time.minute),
                  onChange: onTimeChanged,
                  iosStylePicker: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,

                  // Optional onChange to receive value as DateTime
                  onChangeDateTime: (DateTime dateTime) {},
                ) as Route,
              );
            },
          ),
        ),
        Card(
          clipBehavior: Clip.hardEdge,
          child: DropdownButton<String>(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            value: repeatType,
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down),
            iconSize: 30,

            underline: const SizedBox(),
            // style: TextStyle(
            //   color: Theme.of(context).listTileTheme.textColor,
            // ),
            // dropdownColor: Theme.of(context).scaffoldBackgroundColor,
            onChanged: (String? newValue) {
              setState(() {
                repeatType = newValue!;
              });
            },
            items: <String>[
              "daily".tr,
              "every saturday".tr,
              "every sunday".tr,
              "every monday".tr,
              "every tuesday".tr,
              "every wednesday".tr,
              "every thursday".tr,
              "every Friday".tr,
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                // alignment: Alignment.center,

                value: value,
                child: Text(
                  value,

                  // textAlign: TextAlign.center,
                ),
              );
            }).toList(),
          ),
        ),
      ],
      footer: Row(
        children: [
          Expanded(
            child: ListTile(
              title: Text(
                "done".tr,
                textAlign: TextAlign.center,
              ),
              onTap: () {
                setState(() {
                  if (selectedHour != null) {
                    final DbAlarm alarm = DbAlarm(
                      titleId: widget.dbAlarm.titleId,
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

                    if (widget.isToEdit) {
                      alarmDatabaseHelper.updateAlarmInfo(dbAlarm: alarm);
                      alarmManager.alarmState(dbAlarm: alarm);
                      Navigator.pop(context, alarm);
                    } else {
                      alarm.isActive = true;
                      alarmDatabaseHelper.addNewAlarm(dbAlarm: alarm);
                      alarmManager.alarmState(dbAlarm: alarm);
                      Navigator.pop(context, alarm);
                    }
                  } else {
                    showToast(msg: "please choose time for the reminder".tr);
                  }
                });
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
