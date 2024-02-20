// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/core/repos/app_data.dart';
import 'package:hisnelmoslem/src/core/utils/range_text_formatter.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/quran/data/models/verse_range.dart';
import 'package:hisnelmoslem/src/features/quran/data/repository/uthmani_repository.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

class ZikrContentBuilder extends StatelessWidget {
  final DbContent dbContent;
  const ZikrContentBuilder({
    super.key,
    required this.dbContent,
  });

  @override
  Widget build(BuildContext context) {
    final containsQuranText = dbContent.content.contains("QuranText");
    return containsQuranText
        ? ZikrContentTextWithQuran(
            dbContent: dbContent,
          )
        : ZikrContentPlainText(
            dbContent: dbContent,
          );
  }
}

class ZikrContentPlainText extends StatelessWidget {
  final DbContent dbContent;
  const ZikrContentPlainText({
    super.key,
    required this.dbContent,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      dbContent.content,
      textAlign: TextAlign.center,
      softWrap: true,
      textDirection: TextDirection.rtl,
      style: TextStyle(
        fontSize: appData.fontSize * 10,
        height: 2,
      ),
    );
  }
}

class ZikrContentTextWithQuran extends StatelessWidget {
  final DbContent dbContent;
  const ZikrContentTextWithQuran({
    super.key,
    required this.dbContent,
  });

  Future<List<String>> getQuranText() async {
    final List<String> textList = dbContent.content.split("\n");
    final rangeText = textList.where((e) => e.contains("QuranText")).first;
    final List<VerseRange> ranges = RangeTextFormatter.parse(rangeText);
    hisnPrint(ranges);

    final List<String> verses = [];
    for (final range in ranges) {
      final text = await uthmaniRepository.getArabicText(
        sura: range.startSura,
        startAyah: range.startAyah,
        endAyah: range.endingAyah,
      );
      verses.add(text);
    }

    return verses;
  }

  List<InlineSpan> getTextSpan(List<String> verses) {
    final List<String> textList = dbContent.content.split("\n");
    textList.indexWhere((e) => e.contains("QuranText"));

    final List<InlineSpan> spans = [];

    for (final e in textList) {
      if (e.contains("QuranText")) {
        for (var i = 0; i < verses.length; i++) {
          final List<String> verse = [];
          if (i != 0) verse.add("\n");
          if (i == 0) verse.addAll(["\n", kEstaaza, "\n"]);

          verse.add(kArBasmallah);
          verse.add("\n");
          verse.add(verses[i]);
          verse.add("\n");
          spans.add(
            TextSpan(
              text: verse.join(),
              style: const TextStyle(
                fontFamily: "Uthmanic2",
              ),
            ),
          );
        }
      } else {
        spans.add(TextSpan(text: e));
      }
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getQuranText(),
      builder: (context, snap) {
        if (!snap.hasData) return const LinearProgressIndicator();

        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: getTextSpan(snap.data ?? []),
            style: TextStyle(
              fontSize: appData.fontSize * 10,
              height: 2,
            ),
          ),
        );
      },
    );
  }
}
