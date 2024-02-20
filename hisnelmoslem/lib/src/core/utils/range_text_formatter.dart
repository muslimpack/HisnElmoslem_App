import 'dart:math';

import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/features/quran/data/models/verse_range.dart';

class RangeTextFormatter {
  static List<VerseRange> parse(String text) {
    final RegExp exp = RegExp(r'QuranText\[(\([^)]+\)(?:,\([^)]+\))*)\]');
    final Match? match = exp.firstMatch(text);
    if (match != null) {
      final List<String> ranges = match.group(1)!.split('),');
      final List<VerseRange> parsedRanges = [];
      for (final String range in ranges) {
        final range0 = range.endsWith(")") ? range : "$range)";

        final RegExp rangeExp = RegExp(r'\((\d+):(\d+),(\d+):(\d+)\)');
        final Match? rangeMatch = rangeExp.firstMatch(range0);
        if (rangeMatch != null) {
          final int startSura0 = int.parse(rangeMatch.group(1)!);
          final int startAya0 = int.parse(rangeMatch.group(2)!);
          final int endSura0 = int.parse(rangeMatch.group(3)!);
          final int endAya0 = int.parse(rangeMatch.group(4)!);

          ///
          final int startSura = min(startSura0, endSura0);
          final int startAya = min(startAya0, endAya0);
          final int endSura = max(startSura0, endSura0);
          final int endAya = max(startAya0, endAya0);
          parsedRanges.add(VerseRange(startSura, startAya, endSura, endAya));
        }
      }

      return parsedRanges;
    } else {
      hisnPrint("no match");
      return [];
    }
  }
}
