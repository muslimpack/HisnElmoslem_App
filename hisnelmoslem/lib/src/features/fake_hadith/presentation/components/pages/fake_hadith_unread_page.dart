import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/empty.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/data/models/fake_haith.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/presentation/components/widgets/fake_hadith_card.dart';

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
              title: S.of(context).readAllContent,
              description: S.of(context).prophetSaidLiesIntentional,
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(top: 10),
              itemBuilder: (context, index) {
                return FakeHadithCard(
                  fakeHadith: hadithList[index],
                );
              },
              itemCount: hadithList.length,
            ),
    );
  }
}
