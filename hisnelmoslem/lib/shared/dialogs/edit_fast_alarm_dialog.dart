import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:day_night_time_picker/lib/constants.dart';
import 'package:flutter/material.dart';
import 'package:hisnelmoslem/shared/widgets/scroll_glow_remover.dart';
import 'package:hisnelmoslem/utils/alarm_database_helper.dart';
import 'package:hisnelmoslem/models/alarm.dart';
import 'package:hisnelmoslem/shared/functions/handle_repeat_type.dart';
import 'package:hisnelmoslem/shared/functions/show_toast.dart';
import 'package:hisnelmoslem/utils/alarm_manager.dart';

import '../constants/constant.dart';

Future<dynamic> showFastEditAlarmDialog(
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      titlePadding: EdgeInsets.zero,
      actionsPadding: EdgeInsets.zero,
      buttonPadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      title: Text(
        "تعديل تنبيه",
        style: TextStyle(
          fontFamily: "Uthmanic",
          color: Theme.of(context).listTileTheme.textColor,
        ),
        textAlign: TextAlign.center,
      ),
      content: SizedBox(
          height: 250,
          width: MediaQuery.of(context).size.width * .9,
          child: ScrollGlowRemover(
            child: Center(
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    widget.dbAlarm.title,
                    style: TextStyle(color: mainColor, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const Divider(height: 5),
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
                      contentPadding: EdgeInsets.only(
                          left: 15, bottom: 5, top: 5, right: 15),
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
                        dropdownColor:
                            Theme.of(context).scaffoldBackgroundColor,
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
                  const Divider(height: 5),
                ],
              ),
            ),
          )),
      actions: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: ListTile(
                  title: const Text(
                    "تم",
                    textAlign: TextAlign.center,
                  ),
                  onTap: () {
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

                        alarmDatabaseHelper.updateAlarmInfo(
                            dbAlarm: updateAlarm);
                        alarmManager.alarmState(dbAlarm: updateAlarm);
                        Navigator.pop(context, updateAlarm);
                      } else {
                        showToast(msg: "اختر وقتا للتذكير");
                      }
                    });
                  },
                ),
              ),
              Expanded(
                child: ListTile(
                  title: const Text(
                    "إغلاق",
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
        )
      ],
    );
  }
}
