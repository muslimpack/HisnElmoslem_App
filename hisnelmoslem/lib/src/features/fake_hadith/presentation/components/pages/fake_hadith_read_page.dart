import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/empty.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/data/models/fake_haith.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/presentation/components/widgets/fake_hadith_card.dart';

class FakeHadithReadPage extends StatelessWidget {
  final List<DbFakeHaith> hadithList;

  const FakeHadithReadPage({super.key, required this.hadithList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: hadithList.isEmpty
          ? Empty(
              isImage: false,
              icon: Icons.menu_book,
              title: S.of(context).haveNotReadAnythingYet,
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
