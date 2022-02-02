import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/controllers/alarm_controller.dart';
import 'package:hisnelmoslem/controllers/dashboard_controller.dart';
import 'package:hisnelmoslem/models/alarm.dart';
import 'package:hisnelmoslem/shared/dialogs/edit_fast_alarm_dialog.dart';
import 'package:hisnelmoslem/shared/functions/handle_repeat_type.dart';
import 'package:hisnelmoslem/shared/widgets/round_tag.dart';
import 'package:hisnelmoslem/utils/alarm_database_helper.dart';
import 'package:hisnelmoslem/utils/alarm_manager.dart';

import '../constant.dart';

class AlarmCard extends StatelessWidget {
  final DbAlarm dbAlarm;
  AlarmCard({Key? key, required this.dbAlarm}) : super(key: key);

  //
  final DashboardController dashboardController =
      Get.put(DashboardController());
  Widget alarmCardBody() {
    return GetBuilder<AlarmsPageController>(builder: (controller) {
      return Column(
        children: [
          SwitchListTile(
            title: ListTile(
              contentPadding: EdgeInsets.all(0),
              leading: Icon(
                Icons.alarm,
              ),
              subtitle: Wrap(
                children: [
                  RoundTagCard(
                    name: dbAlarm.body,
                    color: brwon,
                  ),
                  RoundTagCard(
                    name: '⌚ ${dbAlarm.hour} : ${dbAlarm.minute}',
                    color: green,
                  ),
                  RoundTagCard(
                    name: HandleRepeatType()
                        .getNameToUser(chosenValue: dbAlarm.repeatType),
                    color: yellow,
                  ),
                ],
              ),
              isThreeLine: true,
              title: Text(dbAlarm.title),
            ),
            activeColor: MAINCOLOR,
            value: dbAlarm.isActive == 0 ? false : true,
            onChanged: (value) {
              //Update database
              DbAlarm updateAlarm = dbAlarm;
              value ? updateAlarm.isActive = 1 : updateAlarm.isActive = 0;
              alarmDatabaseHelper.updateAlarmInfo(dbAlarm: updateAlarm);
              // update view
              dbAlarm.isActive = value ? 1 : 0;
              //
              alarmManager.alarmState(dbAlarm: updateAlarm);
              //
              controller.update();
              dashboardController.alarms = controller.alarms;
              dashboardController.update();
            },
          ),
          // Divider(),
        ],
      );
    });
  }

//
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AlarmsPageController>(builder: (controller) {
      return new Slidable(
        startActionPane: ActionPane(
          // A motion is a widget used to control how the pane animates.
          motion: const ScrollMotion(),

          // All actions are defined in the children parameter.
          children: [
            // A SlidableAction can have an icon and/or a label.
            SlidableAction(
              onPressed: (val) {
                showFastEditAlarmDialog(
                  context: context,
                  dbAlarm: dbAlarm,
                ).then((value) {
                  int index = controller.alarms.indexOf(dbAlarm);
                  controller.alarms[index] = value;
                  controller.update();
                  dashboardController.alarms = controller.alarms;
                  dashboardController.update();
                });
              },
              backgroundColor: Colors.green.shade300,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'تعديل',
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: ScrollMotion(),
          children: [
            SlidableAction(
              // An action can be bigger than the others.
              flex: 2,
              onPressed: (val) {
                alarmDatabaseHelper.deleteAlarm(dbAlarm: dbAlarm);
                controller.alarms.removeWhere((item) => item == dbAlarm);
                controller.update();
                dashboardController.alarms = controller.alarms;
                dashboardController.update();
              },
              backgroundColor: Colors.red.shade300,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'حذف',
            ),
          ],
        ),
        child: alarmCardBody(),
      );
    });
  }
}
