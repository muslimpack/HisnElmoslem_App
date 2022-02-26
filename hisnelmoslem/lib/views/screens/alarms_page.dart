import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/Shared/Widgets/Loading.dart';
import 'package:hisnelmoslem/controllers/alarm_controller.dart';
import 'package:hisnelmoslem/shared/cards/alarm_card.dart';
import 'package:hisnelmoslem/shared/constants/constant.dart';

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
                title: Text("إدارة تنبيهات الأذكار",
                    style: TextStyle(fontFamily: "Uthmanic")),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
              ),
              body: controller.isLoading
                  ? Loading()
                  : Scrollbar(
                      controller: controller.alarmScrollController,
                      isAlwaysShown: false,
                      child: new ScrollConfiguration(
                        behavior: ScrollBehavior(),
                        child: GlowingOverscrollIndicator(
                          axisDirection: AxisDirection.down,
                          color: black26,
                          child: controller.alarms.length == 0
                              ? Empty(
                                  isImage: false,
                                  icon: Icons.alarm_add_rounded,
                                  title: "لا يوجد أي منبهات",
                                  description:
                                      "لم يتم تعيين منبة لأي ذكر\nإذا أردت تعيين منبة قم بالضغط على علامة المنبة ⏰ بجوار عنوان الذكر",
                                )
                              : ListView.builder(
                                  padding: EdgeInsets.only(top: 10),
                                  itemBuilder: (context, index) {
                                    return AlarmCard(
                                      dbAlarm: controller.alarms[index],
                                    );
                                  },
                                  itemCount: controller.alarms.length,
                                ),
                        ),
                      ),
                    ));
        });
  }
}
