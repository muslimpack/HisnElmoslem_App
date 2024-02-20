class ArabicNumbers {
  static String convert(String text) {
    if (text.isEmpty) return "";

    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    String result = text;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }

    return result;
  }

  String convertByLocale(String text, String localeNumbers) {
    if (text.isEmpty) return "";

    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    String result = text;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], localeNumbers[i]);
    }

    return result;
  }
}
