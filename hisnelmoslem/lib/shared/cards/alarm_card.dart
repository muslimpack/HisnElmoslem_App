import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/controllers/alarm_controller.dart';
import 'package:hisnelmoslem/controllers/dashboard_controller.dart';
import 'package:hisnelmoslem/models/alarm.dart';
import 'package:hisnelmoslem/shared/constants/constant.dart';
import 'package:hisnelmoslem/shared/dialogs/edit_fast_alarm_dialog.dart';
import 'package:hisnelmoslem/shared/functions/handle_repeat_type.dart';
import 'package:hisnelmoslem/shared/widgets/round_tag.dart';
import 'package:hisnelmoslem/utils/alarm_database_helper.dart';
import 'package:hisnelmoslem/utils/alarm_manager.dart';
import '../functions/get_snackbar.dart';

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
              leading: Icon(Icons.alarm),
              subtitle: Wrap(
                children: [
                  dbAlarm.body.isEmpty
                      ? SizedBox()
                      : RoundTagCard(
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
      return new Slidable(
        startActionPane: ActionPane(
          extentRatio: .3,
          motion: const BehindMotion(),
          children: [
            SlidableAction(
              onPressed: (val) {
                debugPrint(dbAlarm.toString());

                showFastEditAlarmDialog(
                  context: context,
                  dbAlarm: dbAlarm,
                ).then((value) {
                  debugPrint(value.toString());

                  if (value.hasAlarmInside) {
                    int index = controller.alarms.indexOf(dbAlarm);
                    controller.alarms[index] = value;
                    //
                    dashboardController.alarms = controller.alarms;
                    dashboardController.update();
                    //
                    controller.update();
                    //
                    debugPrint("showFastEditAlarmDialog Done");
                  }
                });
              },
              backgroundColor: green,
              foregroundColor: white,
              icon: Icons.edit,
              label: 'تعديل',
            ),
          ],
        ),
        endActionPane: ActionPane(
          extentRatio: .3,
          motion: const BehindMotion(),
          children: [
            SlidableAction(
              // An action can be bigger than the others.

              onPressed: (val) {
                alarmDatabaseHelper.deleteAlarm(dbAlarm: dbAlarm);
                controller.alarms.removeWhere((item) => item == dbAlarm);
                controller.update();
                dashboardController.alarms = controller.alarms;
                dashboardController.update();
                // Get.snackbar("رسالة", "تم حذف منبه ${dbAlarm.title}",
                //     duration: const Duration(seconds: 1),
                //     icon: Image.asset("assets/images/app_icon.png"));

                getSnackbar(message: "تم حذف منبه ${dbAlarm.title}");
              },
              backgroundColor: red,
              foregroundColor: white,
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
