import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/app/modules/rearrange_dashboard/rearrange_dashboard_page_controller.dart';
import 'package:hisnelmoslem/app/shared/functions/print.dart';
import 'package:hisnelmoslem/app/views/dashboard/dashboard_controller.dart';
import 'package:hisnelmoslem/core/values/app_dashboard.dart';
import 'package:hisnelmoslem/core/values/constant.dart';

class ScreenAppBar extends StatelessWidget {
  final DashboardController controller;

  const ScreenAppBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: controller.isSearching
          ? TextFormField(
              style: TextStyle(color: mainColor, decorationColor: mainColor),
              textAlign: TextAlign.center,
              controller: controller.searchController,
              autofocus: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                hintText: "search".tr,
                contentPadding: const EdgeInsets.only(
                  left: 15,
                  bottom: 5,
                  top: 5,
                  right: 15,
                ),
                prefix: IconButton(
                  icon: const Icon(Icons.clear_all),
                  onPressed: () {
                    controller.searchController.clear();
                    controller.searchZikr();
                    controller.update();
                  },
                ),
              ),
              onChanged: (value) {
                controller.searchZikr();
              },
            )
          : SizedBox(
              width: 40,
              child: Image.asset(
                'assets/images/app_icon.png',
              ),
            ),
      pinned: true,
      floating: true,
      snap: true,
      bottom: PreferredSize(
        preferredSize: const Size(0, 48),
        child: GetBuilder<RearrangeDashboardPageController>(
          init: RearrangeDashboardPageController(),
          builder: (rearrangeController) {
            return TabBar(
              indicatorColor: mainColor,
              controller: controller.tabController,
              // labelColor: mainColor,
              // unselectedLabelColor: null,
              // controller: tabController,
              tabs: [
                ...List.generate(
                  appDashboardItem.length,
                  (index) {
                    hisnPrint("rebuild");
                    return Tab(
                      child: Text(
                        appDashboardItem[rearrangeController.list[index]].title,
                        style: const TextStyle(
                          fontFamily: "Uthmanic",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        if (controller.isSearching)
          IconButton(
            splashRadius: 20,
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.exit_to_app_sharp),
            onPressed: () {
              controller.isSearching = false;
              controller.searchedTitle = controller.allTitle;
              // controller.searchController.clear();
              controller.update();
            },
          )
        else
          IconButton(
            splashRadius: 20,
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.search),
            onPressed: () {
              controller.searchZikr();
            },
          ),
        if (controller.isSearching)
          const SizedBox()
        else
          IconButton(
            splashRadius: 20,
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.vertical_split_rounded),
            onPressed: () {
              controller.toggleDrawer();
            },
          ),
      ],
    );
  }
}
