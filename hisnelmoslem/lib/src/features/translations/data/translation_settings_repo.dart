import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/src/features/translations/domain/translation_resolver.dart';

/// Translation preferences. The switches are `null` until the user touches them, so their
/// default can depend on the device language (see `TranslationResolver.defaultShow`).
class TranslationSettingsRepo {
  static const String langKey = 'translation_lang';
  static const String showMeaningKey = 'translation_show_meaning';
  static const String showTranslitKey = 'translation_show_translit';
  static const String showTitlesKey = 'translation_show_titles';

  final GetStorage box;
  TranslationSettingsRepo(this.box);

  /// `auto` or a language code.
  String get lang => box.read<String>(langKey) ?? TranslationResolver.auto;
  Future<void> changeLang(String value) => box.write(langKey, value);

  bool? get showMeaning => box.read<bool>(showMeaningKey);
  Future<void> changeShowMeaning({required bool value}) => box.write(showMeaningKey, value);

  bool? get showTranslit => box.read<bool>(showTranslitKey);
  Future<void> changeShowTranslit({required bool value}) => box.write(showTranslitKey, value);

  bool? get showTitles => box.read<bool>(showTitlesKey);
  Future<void> changeShowTitles({required bool value}) => box.write(showTitlesKey, value);
}
