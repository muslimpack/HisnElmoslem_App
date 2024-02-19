import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import "package:hisnelmoslem/app/data/models/models.dart";
import 'package:hisnelmoslem/app/modules/alarms_manager/alarm_controller.dart';
import 'package:hisnelmoslem/src/core/functions/get_snackbar.dart';
import 'package:hisnelmoslem/src/core/functions/handle_repeat_type.dart';
import 'package:hisnelmoslem/src/core/shared/dialogs/alarm_dialog.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/round_tag.dart';
import 'package:hisnelmoslem/src/core/utils/alarm_database_helper.dart';
import 'package:hisnelmoslem/src/core/utils/alarm_manager.dart';
import 'package:hisnelmoslem/src/core/utils/awesome_notification_manager.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/home/presentation/controller/dashboard_controller.dart';

class AlarmCard extends StatelessWidget {
  final DbAlarm dbAlarm;

  AlarmCard({super.key, required this.dbAlarm});

  //
  final DashboardController dashboardController =
      Get.put(DashboardController());

  Widget alarmCardBody() {
    return GetBuilder<AlarmsPageController>(
      builder: (controller) {
        return Column(
          children: [
            SwitchListTile(
              title: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.alarm),
                subtitle: Wrap(
                  children: [
                    if (dbAlarm.body.isEmpty)
                      const SizedBox()
                    else
                      RoundTagCard(
                        name: dbAlarm.body,
                        color: brown,
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
                    ),
                  ],
                ),
                isThreeLine: true,
                title: Text(dbAlarm.title),
              ),
              activeColor: mainColor,
              value: dbAlarm.isActive,
              onChanged: (value) {
                //Update database
                final DbAlarm updateAlarm = dbAlarm;
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
      },
    );
  }

//
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AlarmsPageController>(
      builder: (controller) {
        return Slidable(
          startActionPane: ActionPane(
            extentRatio: .3,
            motion: const BehindMotion(),
            children: [
              SlidableAction(
                onPressed: (val) {
                  showFastAlarmDialog(
                    context: context,
                    dbAlarm: dbAlarm,
                    isToEdit: true,
                  ).then((value) {
                    if (value is DbAlarm) {
                      if (value.hasAlarmInside) {
                        final int index = controller.alarms.indexOf(dbAlarm);
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
                    message: "${"Reminder Removed".tr} | ${dbAlarm.title}",
                  );
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
      },
    );
  }
}
