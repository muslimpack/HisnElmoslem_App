import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/app/views/dashboard/dashboard_controller.dart';
import "package:hisnelmoslem/app/data/models/models.dart";
import 'package:hisnelmoslem/app/shared/widgets/empty.dart';
import 'package:hisnelmoslem/app/shared/widgets/scroll_glow_custom.dart';
import 'package:hisnelmoslem/core/utils/alarm_database_helper.dart';
import 'package:hisnelmoslem/app/views/dashboard/widgets/title_card.dart';

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
              ? Empty(
                  isImage: false,
                  icon: Icons.bookmark_outline_rounded,
                  title: "nothing found in favourites".tr,
                  description:
                      "no title from the index is marked as a favourite. Click on the Favorites icon at any index title"
                          .tr,
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
