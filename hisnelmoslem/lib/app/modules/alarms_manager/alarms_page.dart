import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/app/modules/alarms_manager/alarm_controller.dart';
import 'package:hisnelmoslem/app/modules/alarms_manager/widgets/alarm_card.dart';
import 'package:hisnelmoslem/app/shared/widgets/empty.dart';
import 'package:hisnelmoslem/app/shared/widgets/loading.dart';

class AlarmsPages extends StatelessWidget {
  const AlarmsPages({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AlarmsPageController>(
      init: AlarmsPageController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              "reminders manager".tr,
              style: const TextStyle(fontFamily: "Uthmanic"),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
          ),
          body: controller.isLoading
              ? const Loading()
              : Scrollbar(
                  controller: controller.alarmScrollController,
                  thumbVisibility: false,
                  child: controller.alarms.isEmpty
                      ? Empty(
                          isImage: false,
                          icon: Icons.alarm_add_rounded,
                          title: "no reminders found".tr,
                          description:
                              "no alarm has been set for any zikr if you want to set an alarm, click on the alarm sign next to the zikr title"
                                  .tr,
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(top: 10),
                          itemBuilder: (context, index) {
                            return AlarmCard(
                              dbAlarm: controller.alarms[index],
                            );
                          },
                          itemCount: controller.alarms.length,
                        ),
                ),
        );
      },
    );
  }
}
