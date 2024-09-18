import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/functions/show_toast.dart';
import 'package:hisnelmoslem/src/core/shared/custom_inputs/custom_field_decoration.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/alarm.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/alarm_repeat_type.dart';
import 'package:intl/intl.dart' hide TextDirection;

Future<DbAlarm?> showAlarmEditorDialog({
  required BuildContext context,
  required DbAlarm dbAlarm,
  required bool isToEdit,
}) async {
  // show the dialog
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlarmEditorDialog(
        dbAlarm: dbAlarm,
        isToEdit: isToEdit,
      );
    },
  );
}

class AlarmEditorDialog extends StatefulWidget {
  final DbAlarm dbAlarm;
  final bool isToEdit;

  const AlarmEditorDialog({
    super.key,
    required this.dbAlarm,
    required this.isToEdit,
  });

  @override
  AlarmEditorDialogState createState() => AlarmEditorDialogState();
}

class AlarmEditorDialogState extends State<AlarmEditorDialog> {
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

  late AlarmRepeatType repeatType;

  @override
  void initState() {
    super.initState();
    if (widget.isToEdit) {
      _time = TimeOfDay.now()
          .replacing(hour: widget.dbAlarm.hour, minute: widget.dbAlarm.minute);

      bodyController = TextEditingController(text: widget.dbAlarm.body);
      repeatType = widget.dbAlarm.repeatType;
      selectedHour = widget.dbAlarm.hour;
      selectedMinute = widget.dbAlarm.minute;
    } else {
      bodyController = TextEditingController(
        text: 'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
      );
      repeatType = AlarmRepeatType.daily;
    }
  }

  @override
  void dispose() {
    bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        () {
          if (widget.isToEdit) {
            return S.of(context).editReminder;
          } else {
            return S.of(context).addReminder;
          }
        }(),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.dbAlarm.title,
            style: const TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          TextField(
            style: TextStyle(
              color: Theme.of(context).listTileTheme.textColor,
            ),
            textAlign: TextAlign.center,
            controller: bodyController,
            maxLength: 100,
            autofocus: true,
            decoration: customInputDecoration.copyWith(
              hintText: S.of(context).setMessageForYou,
              labelText: S.of(context).setMessageForYou,
            ),
          ),
          Card(
            clipBehavior: Clip.hardEdge,
            child: ListTile(
              leading: const Icon(Icons.alarm),
              title: Text(
                selectedHour == null || selectedMinute == null
                    ? S.of(context).clickToChooseTime
                    : DateFormat("hh:mm a").format(
                        DateTime(1, 1, 1, selectedHour!, selectedMinute!),
                      ),
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
            child: DropdownButton<AlarmRepeatType>(
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
              onChanged: (AlarmRepeatType? newValue) {
                if (newValue == null) return;
                setState(() {
                  repeatType = newValue;
                });
              },
              items: AlarmRepeatType.values
                  .map<DropdownMenuItem<AlarmRepeatType>>(
                      (AlarmRepeatType value) {
                return DropdownMenuItem<AlarmRepeatType>(
                  // alignment: Alignment.center,

                  value: value,
                  child: Text(
                    value.getUserFriendlyName(context),

                    // textAlign: TextAlign.center,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text(
            S.of(context).done,
            textAlign: TextAlign.center,
          ),
          onPressed: () {
            setState(() {
              if (selectedHour != null) {
                final editedAlarm = widget.dbAlarm.copyWith(
                  body: bodyController.text,
                  hour: selectedHour,
                  hasAlarmInside: true,
                  minute: selectedMinute,
                  repeatType: repeatType,
                );

                if (widget.isToEdit) {
                  Navigator.pop(context, editedAlarm);
                } else {
                  Navigator.pop(
                    context,
                    editedAlarm.copyWith(isActive: true),
                  );
                }
              } else {
                showToast(msg: S.of(context).chooseTimeForReminder);
              }
            });
          },
        ),
        TextButton(
          child: Text(
            S.of(context).close,
            textAlign: TextAlign.center,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
