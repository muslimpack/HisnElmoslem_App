import 'package:hisnelmoslem/src/core/values/constant.dart';

extension StringExtension on String {
  String get removeDiacritics {
    return replaceAll(RegExp(String.fromCharCodes(kArabicDiacriticsChar)), "");
  }

  String get removeTextInBrackets {
    final RegExp regExp = RegExp(r'\(.*?\)');
    return replaceAll(regExp, "");
  }

  String truncateText(int maxChars) {
    if (length <= maxChars) {
      return this;
    } else {
      return '${substring(0, maxChars)}...';
    }
  }

  String truncateTextAroundWordByChar(String selectedWord, int maxChars) {
    final int wordIndex = indexOf(selectedWord);

    if (wordIndex < 0) {
      // The selected word is not found, return the original text
      return this;
    }

    // Calculate the start and end indices for the truncated text
    int start = wordIndex - maxChars ~/ 2;
    int end = wordIndex + selectedWord.length + maxChars ~/ 2;

    // Ensure the start and end indices are within the bounds of the text
    start = start.clamp(0, length - 1);
    end = end.clamp(0, length - 1);

    // Truncate the text and add "..." from the trimmed side
    String truncatedText = substring(start, end);
    if (start > 0) {
      truncatedText = '...$truncatedText';
    }
    if (end < length - 1) {
      truncatedText += '...';
    }

    return truncatedText;
  }

  String truncateTextAroundWordByWord(String selectedWord, int maxWords) {
    final int selectedWordIndex = indexOf(selectedWord);

    // The selected word is not found, return the original text
    if (selectedWordIndex < 0) return this;

    final List<String> words = split(' ');
    int wordStartIndex = -1;
    int wordEndIndex = -1;

    // Find the start and end indices for the selected word
    for (int i = 0, count = 0; i < words.length; i++) {
      final String word = words[i];
      count += word.length + 1; // Add 1 for the space after each word

      if (wordStartIndex == -1 && count > selectedWordIndex) {
        wordStartIndex = i;
      }

      if (wordStartIndex != -1 &&
          count >= selectedWordIndex + selectedWord.length) {
        wordEndIndex = i;
        break;
      }
    }

    // The selected word is not found, return the original text
    if (wordStartIndex < 0) return this;

    // Calculate the start and end indices for the truncated text
    final int start = (wordStartIndex - maxWords).clamp(0, words.length - 1);
    final int end = (wordEndIndex + maxWords).clamp(0, words.length - 1);

    // Truncate the text and add "..." from the trimmed side
    final List<String> truncatedWords = words.sublist(
      start,
      end + 1,
    ); // Include the end index
    if (start > 0) truncatedWords.insert(0, '...');
    if (end < words.length - 1) truncatedWords.add('...');

    return truncatedWords.join(' ');
  }
}
