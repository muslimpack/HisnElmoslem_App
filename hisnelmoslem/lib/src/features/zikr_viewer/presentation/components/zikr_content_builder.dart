// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:hisnelmoslem/src/core/extensions/string_extension.dart';
import 'package:hisnelmoslem/src/core/utils/range_text_formatter.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/quran/data/models/verse_range.dart';
import 'package:hisnelmoslem/src/features/quran/data/repository/uthmani_repository.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

class ZikrContentBuilder extends StatelessWidget {
  final DbContent dbContent;
  final double fontSize;
  final bool enableDiacritics;
  final Color? color;
  const ZikrContentBuilder({
    super.key,
    required this.dbContent,
    required this.fontSize,
    required this.enableDiacritics,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final containsQuranText = dbContent.content.contains("QuranText");
    return containsQuranText
        ? ZikrContentTextWithQuran(
            dbContent: dbContent,
            enableDiacritics: enableDiacritics,
            fontSize: fontSize,
            color: color,
          )
        : ZikrContentPlainText(
            dbContent: dbContent,
            enableDiacritics: enableDiacritics,
            fontSize: fontSize,
            color: color,
          );
  }
}

class ZikrContentPlainText extends StatelessWidget {
  final DbContent dbContent;
  final double fontSize;
  final bool enableDiacritics;
  final Color? color;
  const ZikrContentPlainText({
    super.key,
    required this.dbContent,
    required this.fontSize,
    required this.enableDiacritics,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      enableDiacritics ? dbContent.content : dbContent.content.removeDiacritics,
      textAlign: TextAlign.center,
      softWrap: true,
      textDirection: TextDirection.rtl,
      style: TextStyle(
        fontSize: fontSize,
        height: 2,
        color: color,
      ),
    );
  }
}

class ZikrContentTextWithQuran extends StatelessWidget {
  final DbContent dbContent;
  final double fontSize;
  final bool enableDiacritics;
  final Color? color;
  const ZikrContentTextWithQuran({
    super.key,
    required this.dbContent,
    required this.fontSize,
    required this.enableDiacritics,
    this.color,
  });

  Future<List<String>> getQuranText() async {
    final List<String> textList = dbContent.content.split("\n");
    final rangeText = textList.where((e) => e.contains("QuranText")).first;
    final List<VerseRange> ranges = RangeTextFormatter.parse(rangeText);

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
    final List<String> lines = dbContent.content.split("\n");

    lines.indexWhere((e) => e.contains("QuranText"));

    final List<InlineSpan> spans = [];

    for (var lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final line = lines[lineIndex];

      if (line.contains("QuranText")) {
        if (lineIndex != 0) spans.add(const TextSpan(text: "\n\n"));
        for (var i = 0; i < verses.length; i++) {
          final List<String> verse = [];

          if (i == 0) verse.addAll([kEstaaza, "\n\n"]);

          verse.add(kArBasmallah);

          verse.add(" ﴿ ${verses[i].trim()} ﴾");

          if (i != verses.length - 1) verse.add("\n\n");

          spans.add(
            TextSpan(
              text: enableDiacritics
                  ? verse.join()
                  : verse.join().removeDiacritics,
              style: const TextStyle(
                fontFamily: "Uthmanic2",
              ),
            ),
          );
        }
        if (lineIndex != lines.length - 1) {
          spans.add(const TextSpan(text: "\n\n"));
        }
      } else {
        spans.add(
          TextSpan(
            text: enableDiacritics ? line : line.removeDiacritics,
          ),
        );
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
              fontSize: fontSize,
              height: 2,
              color: color,
            ),
          ),
        );
      },
    );
  }
}
