import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/empty.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/presentation/components/widgets/hadith_card.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/presentation/controller/fake_hadith_controller.dart';

class FakeHadithUnreadPage extends StatelessWidget {
  final FakeHadithController controller;

  const FakeHadithUnreadPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: controller.fakeHadithUnReadList.isEmpty
          ? Empty(
              isImage: false,
              icon: Icons.menu_book_rounded,
              title: S.of(context).you_have_read_all_content,
              description: S
                  .of(context)
                  .the_prophet_said_whoever_tells_lies_about_me_intentionally_should_take_his_seat_in_hellfire,
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(top: 10),
              itemBuilder: (context, index) {
                return HadithCard(
                  fakeHaith: controller.fakeHadithUnReadList[index],
                  scaffoldKey: controller.fakeHadithScaffoldKey,
                );
              },
              itemCount: controller.fakeHadithUnReadList.length,
            ),
    );
  }
}
