import 'package:flutter/material.dart';
import 'package:hisnelmoslem/src/core/extensions/extension.dart';
import 'package:hisnelmoslem/src/core/extensions/string_extension.dart';
import 'package:hisnelmoslem/src/core/extensions/zikr_extension.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/screens/zikr_viewer_screen.dart';

class SearchContentCard extends StatelessWidget {
  final int index;
  final DbContent zikr;
  final String searchText;
  const SearchContentCard({
    super.key,
    required this.index,
    required this.zikr,
    required this.searchText,
  });

  @override
  Widget build(BuildContext context) {
    final isAyah = zikr.content.contains("﴿");

    return ListTile(
      isThreeLine: true,
      leading: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 25),
            child: Text((index + 1).toString()),
          ),
        ),
      ),
      subtitle: FutureBuilder(
        future: zikr.toPlainText(),
        builder: (context, snap) {
          if (!snap.hasData) return const LinearProgressIndicator();
          return ListTile(
            title: Text(
              (snap.data ?? "").removeDiacritics.truncateTextAroundWordByWord(
                searchText,
                7,
              ),
              style: TextStyle(
                fontFamily: isAyah ? "Uthmanic2" : "Kitab",
                fontSize: 25,
                height: 2,
              ),
            ),
          );
        },
      ),
      onTap: () {
        context.push(ZikrViewerScreen(index: zikr.titleId));
      },
    );
  }
}
