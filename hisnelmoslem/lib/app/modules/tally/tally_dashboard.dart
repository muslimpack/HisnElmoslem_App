import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/app/modules/tally/pages/tally_counter.dart';
import 'package:hisnelmoslem/app/modules/tally/pages/tally_list.dart';
import 'package:hisnelmoslem/app/modules/tally/tally_controller.dart';
import 'package:hisnelmoslem/app/shared/widgets/scroll_glow_remover.dart';
import 'package:hisnelmoslem/core/values/constant.dart';

class Tally extends StatelessWidget {
  const Tally({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TallyController>(
      init: TallyController(),
      builder: (controller) => DefaultTabController(
        length: 2,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: ScrollGlowRemover(
            child: NestedScrollView(
              floatHeaderSlivers: true,
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    title: Text("tally".tr),
                    pinned: true,
                    floating: true,
                    snap: true,
                    centerTitle: true,
                    actions: [
                      controller.currentDBTally == null
                          ? const SizedBox()
                          : IconButton(
                              splashRadius: 20,
                              onPressed: () {
                                controller.tallySettings();
                              },
                              icon: const Icon(Icons.settings),
                            ),
                      IconButton(
                        splashRadius: 20,
                        onPressed: () {
                          controller.toggleShuffleMode();
                        },
                        icon: Icon(
                          controller.isShuffleModeOn
                              ? Icons.shuffle_on_rounded
                              : Icons.shuffle_rounded,
                        ),
                      ),
                    ],
                    bottom: TabBar(
                      indicatorColor: mainColor,
                      tabs: [
                        Tab(
                          child: Text(
                            "active tallly".tr,
                            style: const TextStyle(
                              fontFamily: "Uthmanic",
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Tab(
                          child: Text(
                            "counters".tr,
                            style: const TextStyle(
                              fontFamily: "Uthmanic",
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ];
              },
              body: const TabBarView(
                // controller: tabController,
                children: [
                  TallyCounterView(),
                  TallyListView(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
