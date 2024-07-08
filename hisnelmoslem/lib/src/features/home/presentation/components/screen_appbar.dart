import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/values/app_dashboard.dart';
import 'package:hisnelmoslem/src/features/home/presentation/controller/dashboard_controller.dart';
import 'package:hisnelmoslem/src/features/settings/presentation/components/rearrange_dashboard/rearrange_dashboard_page_controller.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ScreenAppBar extends StatelessWidget {
  final DashboardController controller;

  const ScreenAppBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      leading: !controller.isSearching
          ? Padding(
              padding: const EdgeInsets.all(7),
              child: Image.asset(
                'assets/images/app_icon.png',
                fit: BoxFit.cover,
              ),
            )
          : IconButton(
              splashRadius: 20,
              padding: EdgeInsets.zero,
              icon: Icon(MdiIcons.close),
              onPressed: () {
                controller.isSearching = false;
                controller.searchedTitle = controller.allTitle;
                // controller.searchController.clear();
                controller.update();
              },
            ),
      title: !controller.isSearching
          ? null
          : TextFormField(
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
                suffix: IconButton(
                  icon: Icon(MdiIcons.eraser),
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
              controller: controller.tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.center,
              tabs: [
                ...List.generate(
                  appDashboardItem.length,
                  (index) {
                    return Tab(
                      child: Text(
                        appDashboardItem[rearrangeController.list[index]].title,
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
        if (!controller.isSearching)
          IconButton(
            splashRadius: 20,
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.search),
            onPressed: () {
              controller.searchZikr();
            },
          ),
        if (!controller.isSearching)
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
