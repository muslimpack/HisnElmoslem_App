import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/app/modules/fake_hadith/fake_hadith_controller.dart';
import 'package:hisnelmoslem/app/shared/widgets/empty.dart';
import 'package:hisnelmoslem/app/shared/widgets/scroll_glow_custom.dart';
import 'package:hisnelmoslem/app/modules/fake_hadith/widgets/hadith_card.dart';

class FakeHadithUnreadPage extends StatelessWidget {
  final FakeHadithController controller;

  const FakeHadithUnreadPage({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScrollGlowCustom(
        child: controller.fakeHadithUnReadList.isEmpty
            ? Empty(
                isImage: false,
                icon: Icons.menu_book_rounded,
                title: "You have read all content".tr,
                description:
                    'The Prophet (may Allah’s peace and blessings be upon him) said: "Whoever tells lies about me intentionally should take his seat in Hellfire."'
                        .tr,
              )
            : ListView.builder(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.only(top: 10),
                itemBuilder: (context, index) {
                  return HadithCard(
                    fakeHaith: controller.fakeHadithUnReadList[index],
                    scaffoldKey: controller.fakeHadithScaffoldKey,
                  );
                },
                itemCount: controller.fakeHadithUnReadList.length,
              ),
      ),
    );
  }
}
