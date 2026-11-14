import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/src/features/translations/data/translation_settings_repo.dart';
import 'package:hisnelmoslem/src/features/translations/data/translations_db_helper.dart';
import 'package:hisnelmoslem/src/features/translations/data/translations_repo.dart';
import 'package:hisnelmoslem/src/features/translations/presentation/controller/translations_cubit.dart';

import 'translations_fixture.dart';

void main() {
  late GetStorage box;
  late TranslationsDBHelper helper;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => Directory.systemTemp.createTempSync('translations_test').path,
    );
    await GetStorage.init('translations_test');
  });

  setUp(() async {
    box = GetStorage('translations_test');
    await box.erase();
    helper = fixtureHelper();
  });
  tearDown(() => helper.close());

  TranslationsCubit makeCubit({String device = 'en', String app = 'ar'}) => TranslationsCubit(
    TranslationsRepo(helper),
    TranslationSettingsRepo(box),
    deviceLanguage: () => device,
    appLanguage: () => app,
  );

  test('auto with a French device loads French plus English fallback', () async {
    final cubit = makeCubit(device: 'fr');
    await cubit.start();
    final s = cubit.state;
    expect(s.isLoaded, isTrue);
    expect(s.lang, 'fr');
    expect(s.showMeaning && s.showTranslit && s.showTitles, isTrue);

    final t = s.translationFor(10)!;
    expect(t.meaning?.text, 'Louange à Allah');
    // French has no transliteration: the English one is shown, flagged.
    expect(t.translit?.lang, 'en');
    expect(t.translit?.isFallback, isTrue);
    expect(s.titleFor(1)?.text, 'Au réveil');
    expect(s.titleFor(2)?.text, 'Clothes');
    expect(s.titleFor(2)?.isFallback, isTrue);
    await cubit.close();
  });

  test('an Arabic device and app default to everything off, language en', () async {
    final cubit = makeCubit(device: 'ar');
    await cubit.start();
    expect(cubit.state.lang, 'en');
    expect(cubit.state.showMeaning, isFalse);
    expect(cubit.state.translationFor(10), isNull);
    expect(cubit.state.titleFor(1), isNull);
    await cubit.close();
  });

  test('switches persist and hide the fields; custom ids have no translation', () async {
    final cubit = makeCubit();
    await cubit.start();
    await cubit.toggleShowTranslit(show: false);
    expect(cubit.state.translationFor(10)!.translit, isNull);
    expect(box.read<bool>('translation_show_translit'), isFalse);

    await cubit.toggleShowMeaning(show: false);
    expect(cubit.state.translationFor(10), isNull);
    expect(cubit.state.translationFor(null), isNull);
    expect(cubit.state.translationFor(-3), isNull);
    expect(cubit.state.titleFor(-3), isNull);

    await cubit.toggleShowTitles(show: false);
    expect(cubit.state.titleFor(1), isNull);
    await cubit.close();
  });

  test('changing the language reloads and stores the choice', () async {
    final cubit = makeCubit();
    await cubit.start();
    expect(cubit.state.lang, 'en');
    await cubit.changeLanguage('fr');
    expect(cubit.state.lang, 'fr');
    expect(box.read<String>('translation_lang'), 'fr');
    await cubit.close();
  });

  test('a restored unknown language falls back like auto', () async {
    await box.write('translation_lang', 'zz');
    final cubit = makeCubit(device: 'fr');
    await cubit.start();
    expect(cubit.state.lang, 'fr');
    expect(cubit.state.setting, 'zz');
    await cubit.close();
  });

  test('a broken database leaves an empty, loaded state', () async {
    final cubit = TranslationsCubit(
      TranslationsRepo(TranslationsDBHelper(opener: () async => throw StateError('no db'))),
      TranslationSettingsRepo(box),
      deviceLanguage: () => 'en',
      appLanguage: () => 'ar',
    );
    await cubit.start();
    expect(cubit.state.isLoaded, isTrue);
    expect(cubit.state.translationFor(10), isNull);
    await cubit.close();
  });
}
