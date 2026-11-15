import 'package:flutter_test/flutter_test.dart';
import 'package:hisnelmoslem/src/features/translations/data/translations_repo.dart';
import 'package:hisnelmoslem/src/features/translations/domain/zikr_translation.dart';

import 'translations_fixture.dart';

void main() {
  late TranslationsRepo repo;

  setUp(() => repo = TranslationsRepo(fixtureHelper()));
  tearDown(() => repo.dbHelper.close());

  test('languages come ordered by sort_order', () async {
    final languages = await repo.getLanguages();
    expect(languages.map((e) => e.code), ['en', 'fr']);
    expect(languages.first.sourceUrl, 'https://hisnmuslim.com');
    expect(languages.last.hasTranslit, isFalse);
    expect(languages.last.isRtl, isFalse);
  });

  test('titles are read per language', () async {
    expect(await repo.getTitles('en'), {1: 'Waking up', 2: 'Clothes'});
    expect(await repo.getTitles('fr'), {1: 'Au réveil'});
    expect(await repo.getTitles('de'), isEmpty);
  });

  test('contents keep coverage and turn blank fields into null', () async {
    final fr = await repo.getContents('fr');
    expect(fr.keys, [10]);
    expect(fr[10]!.meaning, 'Louange à Allah');
    expect(fr[10]!.translit, isNull);
    expect(fr[10]!.coverage, TranslationCoverage.partial);

    final en = await repo.getContents('en');
    expect(en[11]!.note, 'Recite once');
    expect(en[11]!.coverage, TranslationCoverage.near);
  });
}
