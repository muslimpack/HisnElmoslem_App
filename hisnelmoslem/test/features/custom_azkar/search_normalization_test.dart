import 'package:flutter_test/flutter_test.dart';
import 'package:hisnelmoslem/src/core/extensions/string_extension.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';

void main() {
  test("normalizedForSearch lets plain letters match decorated Arabic", () {
    expect(
      "أَذْكَارُ الاسْتِيقَاظِ مِنَ النَّوْمِ".normalizedForSearch,
      "اذكار الاستيقاظ من النوم",
    );
    expect("اذكار الاستيقاظ".normalizedForSearch, "اذكار الاستيقاظ");
  });

  test("DbTitle reads the search column of the original database", () {
    final title = DbTitle.fromMap(const {
      'id': 3,
      'name': 'أَذْكَارُ الاسْتِيقَاظِ',
      'freq': '',
      'order': 3,
      'search': 'أذكار الاستيقاظ',
    });
    expect(title.search, 'أذكار الاستيقاظ');
    expect(title.search.normalizedForSearch.contains("اذكار الاستيقاظ"), isTrue);
  });
}
