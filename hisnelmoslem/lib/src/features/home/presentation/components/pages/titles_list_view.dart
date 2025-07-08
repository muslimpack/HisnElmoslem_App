// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/widgets/title_card.dart';

class HomeTitlesListView extends StatelessWidget {
  final List<DbTitle> titles;
  const HomeTitlesListView({super.key, required this.titles});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemBuilder: (context, index) {
        return TitleCard(dbTitle: titles[index]);
      },
      itemCount: titles.length,
    );
  }
}
