import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/controllers/dashboard_controller.dart';
import 'package:hisnelmoslem/shared/widgets/loading.dart';
import 'package:hisnelmoslem/shared/constant.dart';
import 'package:hisnelmoslem/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/views/pages/bookmarks.dart';
import 'package:hisnelmoslem/views/pages/favorite_zikr.dart';
import 'package:hisnelmoslem/views/pages/fehrs.dart';
import 'package:hisnelmoslem/views/screens/app_update_news.dart';
import 'package:hisnelmoslem/views/screens/fake_hadith.dart';
import 'package:hisnelmoslem/views/screens/quran_read_page.dart';
import 'package:hisnelmoslem/views/screens/settings.dart';
import 'package:hisnelmoslem/views/screens/tally.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class AzkarDashboard extends StatelessWidget {
  final String? payload;
  AzkarDashboard({Key? key, required this.payload}) : super(key: key);

  @override
  build(BuildContext context) {
    return GetBuilder<DashboardController>(
      init: DashboardController(),
      builder: (controller) => controller.isLoading
          ? Loading()
          : DefaultTabController(
              length: 3,
              child: Scaffold(
                body: NestedScrollView(
                  floatHeaderSlivers: true,
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        title: controller.isSearching
                            ? TextFormField(
                                style: TextStyle(decorationColor: MAINCOLOR),
                                textAlign: TextAlign.center,
                                controller: controller.searchController,
                                autofocus: true,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    hintText: "البحث",
                                    contentPadding: EdgeInsets.only(
                                        left: 15, bottom: 5, top: 5, right: 15),
                                    prefix: IconButton(
                                      icon: Icon(Icons.clear_all),
                                      onPressed: () {
                                        controller.searchController.clear();
                                        controller.searchZikr();
                                        controller.update();
                                      },
                                    )),
                                onChanged: (value) {
                                  controller.searchZikr();
                                },
                              )
                            : GestureDetector(
                                onLongPress: () {
                                  transitionAnimation.fromBottom2Top(
                                      context: context,
                                      goToPage: QuranReadPage());
                                },
                                onTap: () {
                                  transitionAnimation.fromBottom2Top(
                                      context: context,
                                      goToPage: AppUpdateNews());
                                },
                                child: Image.asset(
                                  'assets/images/app_icon.png',
                                  scale: 6,
                                ),
                              ),
                        pinned: true,
                        floating: true,
                        snap: true,
                        bottom: TabBar(
                            indicatorColor: bleuShade200,
                            labelColor: bleuShade200,
                            unselectedLabelColor: white,
                            // controller: tabController,
                            tabs: [
                              Tab(
                                child: Text(
                                  "الفهرس",
                                  style: TextStyle(
                                      fontFamily: "Uthmanic",
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Tab(
                                child: Text(
                                  "المفضلة",
                                  style: TextStyle(
                                      fontFamily: "Uthmanic",
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Tab(
                                child: Text(
                                  "مفضلة الأذكار ",
                                  style: TextStyle(
                                      fontFamily: "Uthmanic",
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ]),
                        actions: [
                          controller.isSearching
                              ? IconButton(
                                  splashRadius: 20,
                                  padding: EdgeInsets.all(0),
                                  icon: Icon(Icons.exit_to_app_sharp),
                                  onPressed: () {
                                    controller.isSearching = false;
                                    controller.searchedTitle =
                                        controller.allTitle;
                                    // controller.searchController.clear();
                                    controller.update();
                                  })
                              : IconButton(
                                  splashRadius: 20,
                                  padding: EdgeInsets.all(0),
                                  icon: Icon(Icons.search),
                                  onPressed: () {
                                    controller.searchZikr();
                                  }),
                          controller.isSearching
                              ? SizedBox()
                              : IconButton(
                                  splashRadius: 20,
                                  padding: EdgeInsets.all(0),
                                  icon: Icon(Icons.watch_outlined),
                                  onPressed: () {
                                    transitionAnimation.fromBottom2Top(
                                        context: context, goToPage: Tally());
                                  }),
                          controller.isSearching
                              ? SizedBox()
                              : IconButton(
                                  splashRadius: 20,
                                  padding: EdgeInsets.all(0),
                                  icon: Icon(
                                    MdiIcons.bookOpenPageVariant,
                                  ),
                                  onPressed: () {
                                    transitionAnimation.fromBottom2Top(
                                        context: context,
                                        goToPage: FakeHadith());
                                  }),
                          IconButton(
                              splashRadius: 20,
                              padding: EdgeInsets.all(0),
                              icon: Icon(Icons.settings),
                              onPressed: () {
                                transitionAnimation.fromBottom2Top(
                                    context: context, goToPage: Settings());
                              }),
                        ],
                      ),
                    ];
                  },
                  body: TabBarView(
                    // controller: tabController,
                    children: [
                      AzkarFehrs(),
                      AzkarBookmarks(),
                      FavouriteZikr(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
