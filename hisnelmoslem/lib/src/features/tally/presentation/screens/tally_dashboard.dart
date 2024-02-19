import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/components/pages/tally_counter.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/components/pages/tally_list.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/controller/tally_controller.dart';

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
          body: NestedScrollView(
            physics: const BouncingScrollPhysics(),
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
                    if (controller.currentDBTally == null)
                      const SizedBox()
                    else
                      IconButton(
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
                    tabs: [
                      Tab(
                        child: Text(
                          "active tallly".tr,
                          style: const TextStyle(
                            fontFamily: "Uthmanic",
                          ),
                        ),
                      ),
                      Tab(
                        child: Text(
                          "counters".tr,
                          style: const TextStyle(
                            fontFamily: "Uthmanic",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
            body: const TabBarView(
              physics: BouncingScrollPhysics(),
              // controller: tabController,
              children: [
                TallyCounterView(),
                TallyListView(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
