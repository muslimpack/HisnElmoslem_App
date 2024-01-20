import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/core/values/constant.dart';

class FakehadithAppBar extends StatelessWidget {
  const FakehadithAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Text("fake hadith".tr),
      centerTitle: true,
      elevation: 0,
      pinned: true,
      floating: true,
      snap: true,
      bottom: PreferredSize(
        preferredSize: const Size(0, 50),
        child: TabBar(
          indicatorColor: mainColor,
          tabs: [
            Tab(
              child: Text(
                "new".tr,
                style: const TextStyle(
                  fontFamily: "Uthmanic",
                ),
              ),
            ),
            Tab(
              child: Text(
                "have been read".tr,
                style: const TextStyle(
                  fontFamily: "Uthmanic",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
