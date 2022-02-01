import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/controllers/dashboard_controller.dart';
import 'package:hisnelmoslem/models/alarm.dart';
import 'package:hisnelmoslem/shared/cards/zikr_card.dart';

class AzkarBookmarks extends StatelessWidget {
  const AzkarBookmarks({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(builder: (controller) {
      return Scaffold(
        body: Scrollbar(
          controller: controller.bookmarksScrollController,
          isAlwaysShown: false,
          child: new ListView.builder(
            padding: EdgeInsets.only(top: 10),
            itemBuilder: (context, index) {
              return ZikrCard(
                fehrsTitle: controller.favouriteTitle[index],
                //controller.alarms
                alarm: DbAlarm(id: index),
              );
            },
            itemCount: controller.favouriteTitle.length,
          ),
        ),
      );
    });
  }
}
