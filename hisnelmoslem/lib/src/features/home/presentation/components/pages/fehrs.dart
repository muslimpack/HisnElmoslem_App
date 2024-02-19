import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/empty.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/repository/alarm_database_helper.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/widgets/title_card.dart';
import 'package:hisnelmoslem/src/features/home/presentation/controller/dashboard_controller.dart';

class AzkarFehrs extends StatelessWidget {
  const AzkarFehrs({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      builder: (controller) {
        final List<DbTitle> titleListToDisplay = controller.searchedTitle;
        return Scaffold(
          body: Scrollbar(
            controller: controller.fehrsScrollController,
            thumbVisibility: false,
            child: titleListToDisplay.isEmpty
                ? Empty(
                    isImage: false,
                    icon: Icons.search_outlined,
                    title: "no title with this name".tr,
                    description: "please review the index of the book".tr,
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(top: 10),
                    itemCount: titleListToDisplay.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder(
                        future: alarmDatabaseHelper.getAlarmByZikrTitle(
                          dbTitle: titleListToDisplay[index],
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return TitleCard(
                              index: index,
                              fehrsTitle: titleListToDisplay[index],
                              dbAlarm: snapshot.data!,
                            );
                          } else {
                            return const ListTile();
                          }
                        },
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
