import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/empty.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/repository/alarm_database_helper.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/widgets/title_card.dart';
import 'package:hisnelmoslem/src/features/home/presentation/controller/dashboard_controller.dart';

class AzkarBookmarks extends StatelessWidget {
  const AzkarBookmarks({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      builder: (controller) {
        return Scaffold(
          body: Scrollbar(
            controller: controller.bookmarksScrollController,
            thumbVisibility: false,
            child: controller.favouriteTitle.isEmpty
                ? Empty(
                    isImage: false,
                    icon: Icons.bookmark_outline_rounded,
                    title: "nothing found in favorites".tr,
                    description:
                        "no title from the index is marked as a favourite. Click on the Favorites icon at any index title"
                            .tr,
                  )
                : ListView.builder(
                    controller: controller.bookmarksScrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(top: 10),
                    itemBuilder: (context, index) {
                      return FutureBuilder(
                        future: alarmDatabaseHelper.getAlarmByZikrTitle(
                          dbTitle: controller.favouriteTitle[index],
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return TitleCard(
                              index: index,
                              fehrsTitle: controller.favouriteTitle[index],
                              dbAlarm: snapshot.data!,
                            );
                          } else {
                            return const ListTile();
                          }
                        },
                      );
                    },
                    itemCount: controller.favouriteTitle.length,
                  ),
          ),
        );
      },
    );
  }
}
