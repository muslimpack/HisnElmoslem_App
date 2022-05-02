import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/controllers/tally_controller.dart';
import 'package:hisnelmoslem/shared/constants/constant.dart';
import 'package:hisnelmoslem/shared/widgets/scroll_glow_remover.dart';
import 'package:hisnelmoslem/views/tally/pages/tally_counter.dart';
import 'package:hisnelmoslem/views/tally/pages/tally_list.dart';

class Tally extends StatelessWidget {
  const Tally({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TallyController>(
      init: TallyController(),
      builder: (controller) => DefaultTabController(
        length: 2,
        child: Scaffold(
          body: ScrollGlowRemover(
            child: NestedScrollView(
              floatHeaderSlivers: true,
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    title: const Text("السبحة"),
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
                    ],
                    bottom: const TabBar(indicatorColor: mainColor, tabs: [
                      Tab(
                        child: Text(
                          "التسبيح",
                          style: TextStyle(
                              fontFamily: "Uthmanic",
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Tab(
                        child: Text(
                          "عرض التسبيحات",
                          style: TextStyle(
                            fontFamily: "Uthmanic",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ]),
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
