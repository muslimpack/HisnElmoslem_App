import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/controllers/dashboard_controller.dart';
import 'package:hisnelmoslem/models/alarm.dart';
import 'package:hisnelmoslem/shared/cards/title_card.dart';
import 'package:hisnelmoslem/shared/widgets/scroll_glow_custom.dart';

import '../../shared/widgets/empty.dart';

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
          child: controller.favouriteTitle.isEmpty
              ? const Empty(
                  isImage: false,
                  icon: Icons.bookmark_outline_rounded,
                  title: "لا يوجد شيء في المفضلة",
                  description:
                      "لم يتم تحديد أي عنوان من الفهرس كمفضل \nقم بالضغط على علامة المفضلة 🔖 عند أي عنوان فهرس ",
                )
              : ScrollGlowCustom(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 10),
                    itemBuilder: (context, index) {
                      //TODO get rid of this for loop
                      DbAlarm tempAlarm = DbAlarm(
                          titleId: controller.favouriteTitle[index].orderId);
                      for (var item in controller.alarms) {
                        // debugPrint(item.toString());
                        if (item.title ==
                            controller.favouriteTitle[index].name) {
                          tempAlarm = item;
                        }
                      }
                      controller.favouriteTitle
                          .sort((a, b) => a.orderId.compareTo(b.orderId));
                      return TitleCard(
                        fehrsTitle: controller.favouriteTitle[index],
                        //controller.alarms
                        dbAlarm: tempAlarm,
                      );
                    },
                    itemCount: controller.favouriteTitle.length,
                  ),
                ),
        ),
      );
    });
  }
}
