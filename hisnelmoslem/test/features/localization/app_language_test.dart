import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/localization/domain/app_language.dart';
import 'package:hisnelmoslem/src/features/localization/presentation/screens/app_language_screen.dart';

Map<String, dynamic> _arb(String name) =>
    jsonDecode(File('lib/l10n/$name.arb').readAsStringSync()) as Map<String, dynamic>;

void main() {
  group('AppLanguages', () {
    test('lists Arabic, English and French with native names', () {
      expect(AppLanguages.codes, ['ar', 'en', 'fr']);
      expect(AppLanguages.all.map((l) => l.nativeName), ['العربية', 'English', 'Français']);
    });

    test('matches the generated supported locales', () {
      expect(
        AppLanguages.codes.toSet(),
        S.supportedLocales.map((l) => l.languageCode).toSet(),
      );
    });

    test('only Arabic is right to left', () {
      expect(AppLanguages.byCode('ar')!.isRtl, isTrue);
      expect(AppLanguages.byCode('en')!.isRtl, isFalse);
      expect(AppLanguages.byCode('fr')!.isRtl, isFalse);
    });

    test('nativeNameOf falls back to the code', () {
      expect(AppLanguages.nativeNameOf('fr'), 'Français');
      expect(AppLanguages.nativeNameOf('de'), 'de');
    });

    test('resolveCode keeps supported languages and drops the region', () {
      expect(AppLanguages.resolveCode('fr'), 'fr');
      expect(AppLanguages.resolveCode('fr_FR'), 'fr');
      expect(AppLanguages.resolveCode('fr-CA'), 'fr');
      expect(AppLanguages.resolveCode('EN'), 'en');
      expect(AppLanguages.resolveCode('ar'), 'ar');
    });

    test('resolveCode falls back to Arabic for unknown or missing languages', () {
      expect(AppLanguages.resolveCode(null), 'ar');
      expect(AppLanguages.resolveCode(''), 'ar');
      expect(AppLanguages.resolveCode('de'), 'ar');
    });
  });

  group('French localization', () {
    test('fr.arb has exactly the keys and placeholders of en.arb', () {
      final en = _arb('en');
      final fr = _arb('fr');
      expect(fr['@@locale'], 'fr');
      expect(fr.keys.toSet(), en.keys.toSet());
      final placeholder = RegExp(r'\{\w+\}');
      for (final key in en.keys.where((k) => !k.startsWith('@'))) {
        expect(
          placeholder.allMatches(fr[key] as String).map((m) => m[0]).toSet(),
          placeholder.allMatches(en[key] as String).map((m) => m[0]).toSet(),
          reason: key,
        );
      }
    });

    test('the delegate loads French', () async {
      final s = await S.delegate.load(const Locale('fr'));
      expect(s.appLanguage, "Langue de l'application");
      expect(s.tallyCountOf(3, 33), '3 sur 33');
    });
  });

  testWidgets('AppLanguageTile shows the native name and reports taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppLanguageTile(
            language: AppLanguages.byCode('fr')!,
            selected: true,
            onTap: () => taps++,
          ),
        ),
      ),
    );
    expect(find.text('Français'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
    await tester.tap(find.text('Français'));
    expect(taps, 1);
  });
}
