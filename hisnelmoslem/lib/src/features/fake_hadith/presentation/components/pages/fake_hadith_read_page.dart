import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/empty.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/presentation/components/widgets/hadith_card.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/presentation/controller/fake_hadith_controller.dart';

class FakeHadithReadPage extends StatelessWidget {
  final FakeHadithController controller;

  const FakeHadithReadPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: controller.fakeHadithReadList.isEmpty
          ? Empty(
              isImage: false,
              icon: Icons.menu_book,
              title: S.of(context).you_have_not_read_anything_yet,
              description: S
                  .of(context)
                  .the_prophet_said_whoever_tells_lies_about_me_intentionally_should_take_his_seat_in_hellfire,
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(top: 10),
              itemBuilder: (context, index) {
                return HadithCard(
                  fakeHaith: controller.fakeHadithReadList[index],
                  scaffoldKey: controller.fakeHadithScaffoldKey,
                );
              },
              itemCount: controller.fakeHadithReadList.length,
            ),
    );
  }
}
