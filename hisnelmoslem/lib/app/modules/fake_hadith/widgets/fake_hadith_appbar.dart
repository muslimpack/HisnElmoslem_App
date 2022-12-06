import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/core/values/constant.dart';

class FakehadithAppBar extends StatelessWidget {
  const FakehadithAppBar({Key? key}) : super(key: key);

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
            tabs: const [
              Tab(
                child: Text(
                  "جديد",
                  style: TextStyle(
                      fontFamily: "Uthmanic", fontWeight: FontWeight.bold),
                ),
              ),
              Tab(
                child: Text(
                  "تمت قراءته",
                  style: TextStyle(
                      fontFamily: "Uthmanic", fontWeight: FontWeight.bold),
                ),
              ),
            ],
          )),
    );
  }
}
