import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/controllers/dashboard_controller.dart';
import 'package:hisnelmoslem/models/alarm.dart';
import 'package:hisnelmoslem/shared/cards/zikr_card.dart';

class AzkarFehrs extends StatelessWidget {
  const AzkarFehrs({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(builder: (controller) {
      return Scaffold(
        body: Scrollbar(
            controller: controller.fehrsScrollController,
            isAlwaysShown: false,
            child: new ListView.builder(
              padding: EdgeInsets.only(top: 10),
              itemBuilder: (context, index) {
                //TODO get rid of this for loop

                DbAlarm tempAlarm = DbAlarm(id: index);
                for (var item in controller.alarms) {
                  // debugPrint(item.toString());
                  if (item.id == index) {
                    tempAlarm = item;
                  }
                }
                return ZikrCard(
                  fehrsTitle: controller.isSearching
                      ? controller.searchedTitle[index]
                      : controller.allTitle[index],
                  dbAlarm: tempAlarm,
                );
              },
              itemCount: controller.isSearching
                  ? controller.searchedTitle.length
                  : controller.allTitle.length,
            )),
      );
    });
  }
}
