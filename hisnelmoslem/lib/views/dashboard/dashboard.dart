import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/controllers/dashboard_controller.dart';
import 'package:hisnelmoslem/controllers/quran_controller.dart';
import 'package:hisnelmoslem/shared/widgets/loading.dart';
import 'package:hisnelmoslem/shared/constants/constant.dart';
import 'package:hisnelmoslem/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/shared/widgets/scroll_glow_custom.dart';
import 'package:hisnelmoslem/shared/widgets/scroll_glow_remover.dart';
import 'package:hisnelmoslem/utils/email_manager.dart';
import 'package:hisnelmoslem/views/screens/app_update_news.dart';
import 'package:hisnelmoslem/views/fake_hadith/fake_hadith.dart';
import 'package:hisnelmoslem/views/quran/quran_read_page.dart';
import 'package:hisnelmoslem/views/settings/settings.dart';
import 'package:hisnelmoslem/views/tally/tally_dashboard.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

import '../screens/about.dart';
import 'pages/bookmarks.dart';
import 'pages/favorite_zikr.dart';
import 'pages/fehrs.dart';

class AzkarDashboard extends StatelessWidget {
  const AzkarDashboard({
    Key? key,
  }) : super(key: key);

  @override
  build(BuildContext context) {
    return GetBuilder<DashboardController>(
      init: DashboardController(),
      builder: (controller) => controller.isLoading
          ? const Loading()
          : ZoomDrawer(
              isRtl: true,
              controller: controller.zoomDrawerController,
              menuBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
              menuScreen: MenuScreen(
                controller: controller,
              ),
              mainScreen: MainScreen(
                controller: controller,
              ),
              borderRadius: 24.0,
              showShadow: true,
              angle: 0.0,
              drawerShadowsBackgroundColor: mainColor,
              slideWidth: 250,
            ),
    );
  }
}

class MainScreen extends StatelessWidget {
  final DashboardController controller;
  const MainScreen({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: ScrollGlowRemover(
          child: NestedScrollView(
            floatHeaderSlivers: true,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  title: controller.isSearching
                      ? TextFormField(
                          style: TextStyle(
                              color: mainColor, decorationColor: mainColor),
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
                              contentPadding: const EdgeInsets.only(
                                  left: 15, bottom: 5, top: 5, right: 15),
                              prefix: IconButton(
                                icon: const Icon(Icons.clear_all),
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
                      : SizedBox(
                          width: 40,
                          child: Image.asset(
                            'assets/images/app_icon.png',
                          ),
                        ),
                  pinned: true,
                  floating: true,
                  snap: true,
                  bottom: TabBar(indicatorColor: mainColor,
                      // labelColor: mainColor,
                      // unselectedLabelColor: null,
                      // controller: tabController,
                      tabs: const [
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
                            padding: const EdgeInsets.all(0),
                            icon: const Icon(Icons.exit_to_app_sharp),
                            onPressed: () {
                              controller.isSearching = false;
                              controller.searchedTitle = controller.allTitle;
                              // controller.searchController.clear();
                              controller.update();
                            })
                        : IconButton(
                            splashRadius: 20,
                            padding: const EdgeInsets.all(0),
                            icon: const Icon(Icons.search),
                            onPressed: () {
                              controller.searchZikr();
                            }),
                    controller.isSearching
                        ? const SizedBox()
                        : IconButton(
                            splashRadius: 20,
                            padding: const EdgeInsets.all(0),
                            icon: const Icon(Icons.vertical_split_rounded),
                            onPressed: () {
                              controller.toggleDrawer();
                            }),
                  ],
                ),
              ];
            },
            body: const ScrollGlowCustom(
              axisDirection: AxisDirection.right,
              child: TabBarView(
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
      ),
    );
  }
}

class MenuScreen extends StatelessWidget {
  final DashboardController controller;

  const MenuScreen({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/app_icon.png',
                scale: 1.5,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    "Version " + appVersion,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      controller.toggleTheme();
                    },
                    icon: const Icon(Icons.dark_mode),
                  ),
                ],
              ),
              const Divider(),
            ],
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: ScrollGlowRemover(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.watch_rounded,
                          ),
                          title: const Text("السبحة"),
                          onTap: () {
                            transitionAnimation.fromBottom2Top(
                                context: context, goToPage: const Tally());
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(MdiIcons.bookOpenPageVariant),
                          title: const Text("سورة الكهف"),
                          onTap: () {
                            transitionAnimation.fromBottom2Top(
                                context: context,
                                goToPage: const QuranReadPage(
                                  surahName: SurahNameEnum.alKahf,
                                ));
                          },
                        ),
                        ListTile(
                          leading: const Icon(MdiIcons.bookOpenPageVariant),
                          title: const Text("سورة السجدة"),
                          onTap: () {
                            transitionAnimation.fromBottom2Top(
                                context: context,
                                goToPage: const QuranReadPage(
                                  surahName: SurahNameEnum.assajdah,
                                ));
                          },
                        ),
                        ListTile(
                          leading: const Icon(MdiIcons.bookOpenPageVariant),
                          title: const Text("سورة الملك"),
                          onTap: () {
                            transitionAnimation.fromBottom2Top(
                                context: context,
                                goToPage: const QuranReadPage(
                                  surahName: SurahNameEnum.alMulk,
                                ));
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.menu_book),
                          title: const Text("أحاديث لا تصح"),
                          onTap: () {
                            transitionAnimation.fromBottom2Top(
                                context: context, goToPage: FakeHadith());
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.settings),
                          title: const Text("الإعدادات"),
                          onTap: () {
                            transitionAnimation.fromBottom2Top(
                                context: context, goToPage: Settings());
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.star),
                          title: const Text("تواصل مع المطور"),
                          onTap: () {
                            EmailManager.sendFeedback();
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.history),
                          title: const Text("تاريخ التحديثات"),
                          onTap: () {
                            transitionAnimation.fromBottom2Top(
                                context: context,
                                goToPage: const AppUpdateNews());
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.info),
                          title: const Text("عنا"),
                          onTap: () {
                            transitionAnimation.fromBottom2Top(
                                context: context, goToPage: const About());
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text("إغلاق"),
                onTap: () {
                  controller.toggleDrawer();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
