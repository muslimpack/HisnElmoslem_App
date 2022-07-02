import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/controllers/dashboard_controller.dart';
import 'package:hisnelmoslem/models/alarm.dart';
import 'package:hisnelmoslem/utils/alarm_database_helper.dart';
import 'package:hisnelmoslem/views/dashboard/widgets/title_card.dart';
import 'package:hisnelmoslem/shared/widgets/empty.dart';
import 'package:hisnelmoslem/shared/widgets/scroll_glow_custom.dart';

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
          thumbVisibility: false,
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
                      return FutureBuilder(
                          future: alarmDatabaseHelper.getAlarmByZikrTitle(
                              dbTitle: controller.favouriteTitle[index]),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return TitleCard(
                                index: index,
                                fehrsTitle: controller.favouriteTitle[index],
                                dbAlarm: snapshot.data as DbAlarm,
                              );
                            } else {
                              return const ListTile();
                            }
                          });
                    },
                    itemCount: controller.favouriteTitle.length,
                  ),
                ),
        ),
      );
    });
  }
}
