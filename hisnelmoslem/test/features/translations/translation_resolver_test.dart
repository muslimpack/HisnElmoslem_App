import 'package:flutter_test/flutter_test.dart';
import 'package:hisnelmoslem/src/features/translations/domain/translation_resolver.dart';
import 'package:hisnelmoslem/src/features/translations/domain/zikr_translation.dart';

void main() {
  const available = {'en', 'fr'};

  group('resolveLanguage', () {
    String resolve(String? setting, {String device = 'ar', String app = 'ar'}) =>
        TranslationResolver.resolveLanguage(
          setting: setting,
          deviceLang: device,
          appLang: app,
          available: available,
        );

    test('an available explicit language wins over the device', () {
      expect(resolve('fr', device: 'en'), 'fr');
      expect(resolve('en', device: 'fr'), 'en');
    });

    test('auto follows the device language when available', () {
      expect(resolve('auto', device: 'fr'), 'fr');
      expect(resolve(null, device: 'en'), 'en');
    });

    test('auto uses the app language when the device is not available and app is not ar', () {
      expect(resolve('auto', device: 'de', app: 'fr'), 'fr');
    });

    test('auto resolves to French when the app language is French and the device is Arabic', () {
      expect(resolve('auto', app: 'fr'), 'fr');
      expect(resolve(null, app: 'fr'), 'fr');
    });

    test('auto ends at English for Arabic app and unknown device', () {
      expect(resolve('auto', device: 'de'), 'en');
      expect(resolve('auto'), 'en');
    });

    test('an unknown restored language behaves like auto', () {
      expect(resolve('xx', device: 'fr'), 'fr');
      expect(resolve('xx'), 'en');
    });
  });

  group('defaultShow', () {
    bool show(String? setting, String device, String app) =>
        TranslationResolver.defaultShow(setting: setting, deviceLang: device, appLang: app);

    test('off only when device and app are both Arabic', () {
      expect(show('auto', 'ar', 'ar'), isFalse);
      expect(show('auto', 'ar', 'en'), isTrue);
      expect(show('auto', 'en', 'ar'), isTrue);
    });

    test('on when a language was picked on purpose', () {
      expect(show('fr', 'ar', 'ar'), isTrue);
    });
  });

  group('resolve fallback matrix', () {
    const fr = ZikrTranslation(
      contentId: 1,
      lang: 'fr',
      meaning: 'sens fr',
      coverage: TranslationCoverage.partial,
    );
    const en = ZikrTranslation(
      contentId: 1,
      lang: 'en',
      meaning: 'meaning en',
      translit: 'translit en',
      note: 'note en',
    );

    test('user language wins per field, English fills the gaps and is flagged', () {
      final r = TranslationResolver.resolve(userLang: 'fr', user: fr, english: en);
      expect(r.meaning, const ResolvedField(text: 'sens fr', lang: 'fr'));
      expect(
        r.translit,
        const ResolvedField(text: 'translit en', lang: 'en', isFallback: true),
      );
      expect(r.note?.isFallback, isTrue);
      expect(r.usedFallback, isTrue);
      expect(r.coverage, TranslationCoverage.partial);
    });

    test('nothing in user language falls back to English entirely', () {
      final r = TranslationResolver.resolve(userLang: 'fr', user: null, english: en);
      expect(r.meaning?.lang, 'en');
      expect(r.meaning?.isFallback, isTrue);
      expect(r.coverage, TranslationCoverage.exact);
    });

    test('English as the user language is never a fallback', () {
      final r = TranslationResolver.resolve(userLang: 'en', user: en, english: en);
      expect(r.usedFallback, isFalse);
    });

    test('nothing anywhere hides the field', () {
      final r = TranslationResolver.resolve(userLang: 'fr', user: null, english: null);
      expect(r.isEmpty, isTrue);
      final onlyMeaning = TranslationResolver.resolve(
        userLang: 'en',
        user: const ZikrTranslation(contentId: 2, lang: 'en', meaning: 'm'),
        english: const ZikrTranslation(contentId: 2, lang: 'en', meaning: 'm'),
      );
      expect(onlyMeaning.translit, isNull);
      expect(onlyMeaning.note, isNull);
    });
  });
}
