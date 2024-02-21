import 'dart:async';

import 'package:hisnelmoslem/src/core/utils/range_text_formatter.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/quran/data/models/verse_range.dart';
import 'package:hisnelmoslem/src/features/quran/data/repository/uthmani_repository.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

extension DBContentExt on DbContent {
  Future<List<String>> getQuranVersesText() async {
    if (!content.contains("QuranText")) return [];

    final List<String> textList = content.split("\n");
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

  List<String> getPlainText(List<String> verses) {
    final List<String> lines = content.split("\n");

    lines.indexWhere((e) => e.contains("QuranText"));

    final List<String> spans = [];

    for (var lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final line = lines[lineIndex];

      if (line.contains("QuranText")) {
        if (lineIndex != 0) spans.add("\n\n");
        for (var i = 0; i < verses.length; i++) {
          final List<String> verse = [];

          if (i == 0) verse.addAll([kEstaaza, "\n\n"]);

          verse.add(kArBasmallah);

          verse.add(" ﴿ ${verses[i].trim()} ﴾");

          if (i != verses.length - 1) verse.add("\n\n");

          spans.add(
            verse.join(),
          );
        }
        if (lineIndex != lines.length - 1) {
          spans.add("\n\n");
        }
      } else {
        spans.add(
          line,
        );
      }
    }
    return spans;
  }

  FutureOr<String> getContentText() async {
    if (content.contains("QuranText")) {
      final verses = await getQuranVersesText();
      final text = getPlainText(verses);
      return text.join();
    } else {
      return content;
    }
  }
}
