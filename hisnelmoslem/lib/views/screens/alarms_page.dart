import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/Shared/Widgets/Loading.dart';
import 'package:hisnelmoslem/controllers/alarm_controller.dart';
import 'package:hisnelmoslem/shared/cards/alarm_card.dart';
import 'package:hisnelmoslem/shared/constant.dart';

class AlarmsPages extends StatelessWidget {
  const AlarmsPages({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AlarmsPageController>(
        init: AlarmsPageController(),
        builder: (controller) {
          return Scaffold(
              appBar: AppBar(
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
                          child: new ListView.builder(
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
