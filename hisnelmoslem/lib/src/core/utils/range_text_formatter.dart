import 'package:hisnelmoslem/src/features/quran/data/models/verse_range.dart';

class RangeTextFormatter {
  static List<VerseRange> parse(String text) {
    final RegExp exp = RegExp(r'QuranText\[(\([^)]+\)(?:,\([^)]+\))*)\]');
    final Match? match = exp.firstMatch(text);
    if (match != null) {
      final List<String> ranges = match.group(1)!.split(',');
      final List<VerseRange> parsedRanges = [];
      for (final String range in ranges) {
        final RegExp rangeExp = RegExp(r'\((\d+):(\d+),(\d+):(\d+)\)');
        final Match? rangeMatch = rangeExp.firstMatch(range);
        if (rangeMatch != null) {
          final int startSura = int.parse(rangeMatch.group(1)!);
          final int startAya = int.parse(rangeMatch.group(2)!);
          final int endSura = int.parse(rangeMatch.group(3)!);
          final int endAya = int.parse(rangeMatch.group(4)!);
          parsedRanges.add(VerseRange(startSura, startAya, endSura, endAya));
        }
      }
      return parsedRanges;
    } else {
      throw const FormatException('Invalid Quran text format');
    }
  }
}
