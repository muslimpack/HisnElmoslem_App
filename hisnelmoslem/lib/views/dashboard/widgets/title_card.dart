import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/temp_utils/azkar_database_helper.dart';
import 'package:hisnelmoslem/controllers/dashboard_controller.dart';
import 'package:hisnelmoslem/models/alarm.dart';
import 'package:hisnelmoslem/models/zikr_title.dart';
import 'package:hisnelmoslem/shared/dialogs/add_fast_alarm_dialog.dart';
import 'package:hisnelmoslem/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/temp_utils/alarm_database_helper.dart';
import 'package:hisnelmoslem/utils/alarm_manager.dart';
import 'package:hisnelmoslem/views/azkar/azkar_read_card.dart';
import 'package:hisnelmoslem/views/azkar/azkar_read_page.dart';
import '../../../controllers/app_data_controllers.dart';
import '../../../shared/constants/constant.dart';

class TitleCard extends StatelessWidget {
  final DbTitle fehrsTitle;
  final DbAlarm dbAlarm;
  const TitleCard({Key? key, required this.fehrsTitle, required this.dbAlarm})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(builder: (controller) {
      DbAlarm tempAlarm = dbAlarm;
      return ListTile(
        leading: fehrsTitle.favourite
            ? IconButton(
                icon: Icon(
                  Icons.bookmark,
                  color: mainColor,
                ),
                onPressed: () {
                  azkarDatabaseHelper.deleteTitleFromFavourite(
                      dbTitle: fehrsTitle);
                  //
                  fehrsTitle.favourite = false;
                  //
                  controller.allTitle
                      .firstWhere(
                          (element) => element.orderId == fehrsTitle.orderId)
                      .favourite = false;
                  //
                  controller.favouriteTitle.removeWhere(
                      (item) => item.orderId == fehrsTitle.orderId);
                  //
                  controller.update();
                })
            : IconButton(
                icon: const Icon(Icons.bookmark_border_outlined),
                onPressed: () {
                  //
                  azkarDatabaseHelper.addTitleToFavourite(dbTitle: fehrsTitle);
                  fehrsTitle.favourite = true;
                  //
                  controller.allTitle[fehrsTitle.orderId - 1] = fehrsTitle;
                  controller.favouriteTitle.add(fehrsTitle);
                  //
                  controller.update();
                  //
                }),
        trailing: !dbAlarm.hasAlarmInside
            ? IconButton(
                icon: const Icon(Icons.alarm_add_rounded),
                onPressed: () {
                  dbAlarm.title = fehrsTitle.name;
                  showFastAddAlarmDialog(context: context, dbAlarm: dbAlarm)
                      .then((value) {
                    if (value is DbAlarm) {
                      int index = controller.alarms.indexOf(dbAlarm);
                      if (value.hasAlarmInside) {
                        if (index == -1) {
                          controller.alarms.add(value);
                        } else {
                          controller.alarms[index] = value;
                        }
                        controller.update();
                      }
                    }
                  });
                })
            : tempAlarm.isActive
                ? IconButton(
                    icon: Icon(
                      Icons.notifications_active,
                      color: mainColor,
                    ),
                    onPressed: () {
                      dbAlarm.isActive = tempAlarm.isActive = false;
                      alarmDatabaseHelper.updateAlarmInfo(dbAlarm: dbAlarm);

                      //
                      alarmManager.alarmState(dbAlarm: dbAlarm);
                      //
                      controller.update();
                    })
                : IconButton(
                    icon: Icon(
                      Icons.notifications_off,
                      color: redAccent,
                    ),
                    onPressed: () {
                      dbAlarm.isActive = tempAlarm.isActive = true;
                      alarmDatabaseHelper.updateAlarmInfo(dbAlarm: dbAlarm);

                      //
                      alarmManager.alarmState(dbAlarm: dbAlarm);
                      //
                      controller.update();
                    }),
        title: Text(fehrsTitle.name,
            style: const TextStyle(
                fontFamily: "Uthmanic", fontWeight: FontWeight.bold)),
        // trailing: Text(zikrList[index]),
        onTap: () {
          if (!appData.isCardReadMode) {
            transitionAnimation.circleReval(
                context: Get.context!,
                goToPage: AzkarReadPage(index: fehrsTitle.id));
          } else {
            transitionAnimation.circleReval(
                context: Get.context!,
                goToPage: AzkarReadCard(index: fehrsTitle.id));
          }
        },
      );
    });
  }
}
