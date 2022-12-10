import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/app/views/dashboard/dashboard_controller.dart';
import 'package:hisnelmoslem/app/modules/quran/quran_controller.dart';
import 'package:hisnelmoslem/core/values/constant.dart';
import 'package:hisnelmoslem/app/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/app/shared/widgets/scroll_glow_remover.dart';
import 'package:hisnelmoslem/core/utils/email_manager.dart';
import 'package:hisnelmoslem/app/modules/fake_hadith/fake_hadith.dart';
import 'package:hisnelmoslem/app/modules/quran/quran_read_page.dart';
import 'package:hisnelmoslem/app/modules/about/about.dart';
import 'package:hisnelmoslem/app/modules/app_update_news/app_update_news.dart';
import 'package:hisnelmoslem/app/modules/settings/settings.dart';
import 'package:hisnelmoslem/app/modules/tally/tally_dashboard.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ScreenMenu extends StatelessWidget {
  final DashboardController controller;

  const ScreenMenu({
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
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/app_icon.png',
                      scale: 3,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Hisn Elmoslem App".tr),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              appVersion,
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
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(
                height: 20,
              ),
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
                        DrawerCard(
                          child: ListTile(
                            leading: const Icon(
                              Icons.watch_rounded,
                            ),
                            title: Text("tally".tr),
                            onTap: () {
                              transitionAnimation.fromBottom2Top(
                                context: context,
                                goToPage: const Tally(),
                              );
                            },
                          ),
                        ),
                        const DrawerDivider(),
                        DrawerCard(
                          child: ListTile(
                            leading: const Icon(MdiIcons.bookOpenPageVariant),
                            title: Text(
                              "sura Al-Kahf".tr,
                            ),
                            onTap: () {
                              transitionAnimation.fromBottom2Top(
                                context: context,
                                goToPage: const QuranReadPage(
                                  surahName: SurahNameEnum.alKahf,
                                ),
                              );
                            },
                          ),
                        ),
                        DrawerCard(
                          child: ListTile(
                            leading: const Icon(MdiIcons.bookOpenPageVariant),
                            title: Text("sura As-Sajdah".tr),
                            onTap: () {
                              transitionAnimation.fromBottom2Top(
                                context: context,
                                goToPage: const QuranReadPage(
                                  surahName: SurahNameEnum.assajdah,
                                ),
                              );
                            },
                          ),
                        ),
                        DrawerCard(
                          child: ListTile(
                            leading: const Icon(MdiIcons.bookOpenPageVariant),
                            title: Text("sura Al-Mulk".tr),
                            onTap: () {
                              transitionAnimation.fromBottom2Top(
                                  context: context,
                                  goToPage: const QuranReadPage(
                                    surahName: SurahNameEnum.alMulk,
                                  ));
                            },
                          ),
                        ),
                        const DrawerDivider(),
                        DrawerCard(
                          child: ListTile(
                            leading: const Icon(Icons.menu_book),
                            title: Text("fake hadith".tr),
                            onTap: () {
                              transitionAnimation.fromBottom2Top(
                                context: context,
                                goToPage: const FakeHadith(),
                              );
                            },
                          ),
                        ),
                        const DrawerDivider(),
                        DrawerCard(
                          child: ListTile(
                            leading: const Icon(Icons.settings),
                            title: Text("settings".tr),
                            onTap: () {
                              transitionAnimation.fromBottom2Top(
                                context: context,
                                goToPage: const Settings(),
                              );
                            },
                          ),
                        ),
                        const DrawerDivider(),
                        DrawerCard(
                          child: ListTile(
                            leading: const Icon(Icons.star),
                            title: Text("contact to dev".tr),
                            onTap: () {
                              EmailManager.sendFeedback();
                            },
                          ),
                        ),
                        DrawerCard(
                          child: ListTile(
                            leading: const Icon(Icons.history),
                            title: Text("updates history".tr),
                            onTap: () {
                              transitionAnimation.fromBottom2Top(
                                context: context,
                                goToPage: const AppUpdateNews(),
                              );
                            },
                          ),
                        ),
                        DrawerCard(
                          child: ListTile(
                            leading: const Icon(Icons.info),
                            title: Text("about us".tr),
                            onTap: () {
                              transitionAnimation.fromBottom2Top(
                                context: context,
                                goToPage: const About(),
                              );
                            },
                          ),
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
              const DrawerDivider(),
              DrawerCard(
                child: ListTile(
                  leading: const Icon(Icons.close),
                  title: Text("close".tr),
                  onTap: () {
                    controller.toggleDrawer();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DrawerCard extends StatelessWidget {
  final Widget? child;

  const DrawerCard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child ?? const SizedBox();
  }
}

class DrawerDivider extends StatelessWidget {
  const DrawerDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
    );
  }
}
