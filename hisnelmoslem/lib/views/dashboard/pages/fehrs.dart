import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/controllers/dashboard_controller.dart';
import 'package:hisnelmoslem/models/alarm.dart';
import 'package:hisnelmoslem/models/zikr_title.dart';
import 'package:hisnelmoslem/views/dashboard/widgets/title_card.dart';
import 'package:hisnelmoslem/shared/widgets/empty.dart';
import 'package:hisnelmoslem/shared/widgets/scroll_glow_custom.dart';

class AzkarFehrs extends StatelessWidget {
  const AzkarFehrs({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(builder: (controller) {
      List<DbTitle> titleListToDisplay = controller.searchedTitle;
      return Scaffold(
        body: Scrollbar(
            controller: controller.fehrsScrollController,
            isAlwaysShown: false,
            child: titleListToDisplay.isEmpty
                ? const Empty(
                    isImage: false,
                    icon: Icons.search_outlined,
                    title: "لا يوجد عنوان بهذا الاسم",
                    description: "برجاء قم بمراجعة ما كتبت",
                  )
                : ScrollGlowCustom(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 10),
                      itemCount: titleListToDisplay.length,
                      itemBuilder: (context, index) {
                        //TODO get rid of this for loop

                        DbAlarm tempAlarm =
                            DbAlarm(titleId: titleListToDisplay[index].orderId);
                        for (var item in controller.alarms) {
                          if (item.title == titleListToDisplay[index].name) {
                            tempAlarm = item;
                          }
                        }
                        return TitleCard(
                          fehrsTitle: titleListToDisplay[index],
                          dbAlarm: tempAlarm,
                        );
                      },
                    ),
                  )),
      );
    });
  }
}
