import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/empty.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/data/models/fake_haith.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/presentation/components/widgets/hadith_card.dart';

class FakeHadithUnreadPage extends StatelessWidget {
  final List<DbFakeHaith> hadithList;

  const FakeHadithUnreadPage({super.key, required this.hadithList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: hadithList.isEmpty
          ? Empty(
              isImage: false,
              icon: Icons.menu_book_rounded,
              title: "You have read all content".tr,
              description:
                  'The Prophet (may Allah’s peace and blessings be upon him) said: "Whoever tells lies about me intentionally should take his seat in Hellfire."'
                      .tr,
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(top: 10),
              itemBuilder: (context, index) {
                return HadithCard(
                  fakeHadith: hadithList[index],
                );
              },
              itemCount: hadithList.length,
            ),
    );
  }
}
