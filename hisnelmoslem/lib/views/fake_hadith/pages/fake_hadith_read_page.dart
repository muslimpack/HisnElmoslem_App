import 'package:flutter/material.dart';
import 'package:hisnelmoslem/controllers/fake_hadith_controller.dart';
import 'package:hisnelmoslem/shared/widgets/empty.dart';
import 'package:hisnelmoslem/shared/widgets/scroll_glow_custom.dart';
import 'package:hisnelmoslem/views/fake_hadith/widgets/hadith_card.dart';

class FakeHadithReadPage extends StatelessWidget {
  final FakeHadithController controller;
  const FakeHadithReadPage({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScrollGlowCustom(
        child: controller.fakeHadithReadList.isEmpty
            ? const Empty(
                isImage: false,
                icon: Icons.menu_book,
                title: "لم تقرأ شيئًا بعد",
                description:
                    "قال النبي صلى الله عليه وسلم:\nإنَّ كَذِبًا عليَّ ليس ككذبٍ على أحدٍ ، فمن كذب عليَّ مُتعمِّدًا ، فلْيتبوَّأْ مقعدَه من النَّارِ",
              )
            : ListView.builder(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.only(top: 10),
                itemBuilder: (context, index) {
                  return HadithCard(
                    fakeHaith: controller.fakeHadithReadList[index],
                    scaffoldKey: controller.fakeHadithScaffoldKey,
                  );
                },
                itemCount: controller.fakeHadithReadList.length,
              ),
      ),
    );
  }
}
