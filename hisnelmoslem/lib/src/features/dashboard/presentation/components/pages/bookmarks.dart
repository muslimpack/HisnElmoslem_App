import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/empty.dart';
import 'package:hisnelmoslem/src/features/alarm/data/data_source/alarm_database_helper.dart';
import 'package:hisnelmoslem/src/features/dashboard/presentation/components/widgets/title_card.dart';
import 'package:hisnelmoslem/src/features/dashboard/presentation/controller/dashboard_controller.dart';

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
                    title: S.of(context).nothing_found_in_favorites,
                    description: S
                        .of(context)
                        .no_title_from_index_marked_as_favorite_click_favorites_icon_at_any_index_title,
                  )
                : ListView.builder(
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
