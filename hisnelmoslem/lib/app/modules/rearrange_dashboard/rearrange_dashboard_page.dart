import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/app/modules/rearrange_dashboard/rearrange_dashboard_page_controller.dart';
import 'package:hisnelmoslem/app/shared/widgets/loading.dart';
import 'package:hisnelmoslem/core/values/app_dashboard.dart';

class RearrangeDashboardPage extends StatelessWidget {
  const RearrangeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RearrangeDashboardPageController>(
      init: RearrangeDashboardPageController(),
      builder: (controller) {
        return controller.isLoading
            ? const Loading()
            : Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: Text(
                    "dashboard arrangement".tr,
                    style: const TextStyle(fontFamily: "Uthmanic"),
                  ),
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  elevation: 0,
                ),
                body: ReorderableListView(
                  onReorder: controller.onReorder,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    for (int index = 0;
                        index < controller.list.length;
                        index += 1)
                      ListTile(
                        key: Key('$index'),
                        tileColor: controller.list[index].isOdd
                            ? controller.oddItemColor
                            : controller.evenItemColor,
                        title: Text(
                          appDashboardItem[controller.list[index]].title,
                        ),
                        trailing: const Icon(Icons.horizontal_rule),
                      ),
                  ],
                ),
              );
      },
    );
  }
}
