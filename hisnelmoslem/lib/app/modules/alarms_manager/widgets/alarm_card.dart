import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/app/modules/alarms_manager/alarm_controller.dart';
import 'package:hisnelmoslem/app/views/dashboard/dashboard_controller.dart';
import 'package:hisnelmoslem/app/data/models/alarm.dart';
import 'package:hisnelmoslem/core/values/constant.dart';
import 'package:hisnelmoslem/app/shared/dialogs/edit_fast_alarm_dialog.dart';
import 'package:hisnelmoslem/app/shared/functions/handle_repeat_type.dart';
import 'package:hisnelmoslem/app/shared/widgets/round_tag.dart';
import 'package:hisnelmoslem/core/utils/alarm_database_helper.dart';
import 'package:hisnelmoslem/core/utils/alarm_manager.dart';
import 'package:hisnelmoslem/core/utils/awesome_notification_manager.dart';

import '../../../shared/functions/get_snackbar.dart';

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
              contentPadding: const EdgeInsets.all(0),
              leading: const Icon(Icons.alarm),
              subtitle: Wrap(
                children: [
                  dbAlarm.body.isEmpty
                      ? const SizedBox()
                      : RoundTagCard(
                          name: dbAlarm.body,
                          color: brwon,
                        ),
                  Row(
                    children: [
                      Expanded(
                        child: RoundTagCard(
                          name: '⌚ ${dbAlarm.hour} : ${dbAlarm.minute}',
                          color: green,
                        ),
                      ),
                      Expanded(
                        child: RoundTagCard(
                          name: HandleRepeatType()
                              .getNameToUser(chosenValue: dbAlarm.repeatType),
                          color: yellow,
                        ),
                      ),
                    ],
                  )
                ],
              ),
              isThreeLine: true,
              title: Text(dbAlarm.title),
            ),
            activeColor: mainColor,
            value: dbAlarm.isActive,
            onChanged: (value) {
              //Update database
              DbAlarm updateAlarm = dbAlarm;
              updateAlarm.isActive = value;
              alarmDatabaseHelper.updateAlarmInfo(dbAlarm: updateAlarm);
              // update view
              dbAlarm.isActive = value;
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
      return Slidable(
        startActionPane: ActionPane(
          extentRatio: .3,
          motion: const BehindMotion(),
          children: [
            SlidableAction(
              onPressed: (val) {
                showFastEditAlarmDialog(
                  context: context,
                  dbAlarm: dbAlarm,
                ).then((value) {
                  if (value is DbAlarm) {
                    if (value.hasAlarmInside) {
                      int index = controller.alarms.indexOf(dbAlarm);
                      controller.alarms[index] = value;
                      //
                      dashboardController.alarms = controller.alarms;
                      dashboardController.update();
                      //
                      controller.update();
                    }
                  }
                });
              },
              backgroundColor: green,
              foregroundColor: white,
              icon: Icons.edit,
              label: 'edit'.tr,
            ),
          ],
        ),
        endActionPane: ActionPane(
          extentRatio: .3,
          motion: const BehindMotion(),
          children: [
            SlidableAction(
              onPressed: (val) async {
                await awesomeNotificationManager.cancelNotificationById(
                  id: dbAlarm.titleId,
                );
                await alarmDatabaseHelper.deleteAlarm(dbAlarm: dbAlarm);
                controller.alarms.removeWhere((item) => item == dbAlarm);
                dashboardController.alarms = controller.alarms;

                controller.update();
                dashboardController.update();
                getSnackbar(
                    message: "${"Reminder Removed".tr} | ${dbAlarm.title}");
              },
              backgroundColor: red,
              foregroundColor: white,
              icon: Icons.delete,
              label: "delete".tr,
            ),
          ],
        ),
        child: alarmCardBody(),
      );
    });
  }
}
