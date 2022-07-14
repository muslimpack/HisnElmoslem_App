import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/shared/widgets/loading.dart';
import 'package:hisnelmoslem/controllers/alarm_controller.dart';
import 'package:hisnelmoslem/shared/widgets/scroll_glow_custom.dart';
import 'package:hisnelmoslem/views/alarms_manager/widgets/alarm_card.dart';

import '../../shared/widgets/empty.dart';

class AlarmsPages extends StatelessWidget {
  const AlarmsPages({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AlarmsPageController>(
        init: AlarmsPageController(),
        builder: (controller) {
          return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: const Text("إدارة تنبيهات الأذكار",
                    style: TextStyle(fontFamily: "Uthmanic")),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
              ),
              body: controller.isLoading
                  ? const Loading()
                  : Scrollbar(
                      controller: controller.alarmScrollController,
                      thumbVisibility: false,
                      child: ScrollGlowCustom(
                        child: controller.alarms.isEmpty
                            ? const Empty(
                                isImage: false,
                                icon: Icons.alarm_add_rounded,
                                title: "لا يوجد أي منبهات",
                                description:
                                    "لم يتم تعيين منبة لأي ذكر\nإذا أردت تعيين منبة قم بالضغط على علامة المنبة ⏰ بجوار عنوان الذكر",
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.only(top: 10),
                                itemBuilder: (context, index) {
                                  return AlarmCard(
                                    dbAlarm: controller.alarms[index],
                                  );
                                },
                                itemCount: controller.alarms.length,
                              ),
                      ),
                    ));
        });
  }
}
