import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/empty.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/features/alarm/presentation/controller/alarm_controller.dart';
import 'package:hisnelmoslem/src/features/alarm/presentation/components/alarm_card.dart';

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
              S.of(context).reminders_manager,
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
                          title: S.of(context).no_reminders_found,
                          description: S
                              .of(context)
                              .no_alarm_set_for_any_zikr_if_you_want_set_alarm_click_on_alarm_sign_next_to_zikr_title,
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
