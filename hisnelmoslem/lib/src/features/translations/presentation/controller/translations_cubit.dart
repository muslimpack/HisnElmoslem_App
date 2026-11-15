import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/features/translations/data/translation_settings_repo.dart';
import 'package:hisnelmoslem/src/features/translations/data/translations_repo.dart';
import 'package:hisnelmoslem/src/features/translations/domain/translation_language.dart';
import 'package:hisnelmoslem/src/features/translations/domain/translation_resolver.dart';
import 'package:hisnelmoslem/src/features/translations/domain/zikr_translation.dart';

part 'translations_state.dart';

/// Holds the chosen translation language (and English as the fallback) in memory, so widgets
/// read texts synchronously.
class TranslationsCubit extends Cubit<TranslationsState> {
  final TranslationsRepo repo;
  final TranslationSettingsRepo settings;
  final String Function() deviceLanguage;
  final String Function() appLanguage;

  TranslationsCubit(
    this.repo,
    this.settings, {
    required this.deviceLanguage,
    required this.appLanguage,
  }) : super(const TranslationsState());

  Future<void> start() => _load();

  /// Call after the app language changed: `auto` may resolve to another language.
  Future<void> refresh() => _load();

  Future<void> changeLanguage(String setting) async {
    await settings.changeLang(setting);
    await _load();
  }

  Future<void> toggleShowMeaning({required bool show}) async {
    await settings.changeShowMeaning(value: show);
    emit(state.copyWith(showMeaning: show));
  }

  Future<void> toggleShowTranslit({required bool show}) async {
    await settings.changeShowTranslit(value: show);
    emit(state.copyWith(showTranslit: show));
  }

  Future<void> toggleShowTitles({required bool show}) async {
    await settings.changeShowTitles(value: show);
    emit(state.copyWith(showTitles: show));
  }

  Future<void> _load() async {
    final setting = settings.lang;
    final deviceLang = deviceLanguage();
    final appLang = appLanguage();
    bool defaultShow() =>
        TranslationResolver.defaultShow(setting: setting, deviceLang: deviceLang, appLang: appLang);

    try {
      final languages = await repo.getLanguages();
      final lang = TranslationResolver.resolveLanguage(
        setting: setting,
        deviceLang: deviceLang,
        appLang: appLang,
        available: {for (final l in languages) l.code},
      );
      const en = TranslationResolver.fallbackLang;
      final contents = await repo.getContents(lang);
      final titles = await repo.getTitles(lang);
      final sameAsEnglish = lang == en;
      emit(
        TranslationsState(
          isLoaded: true,
          setting: setting,
          lang: lang,
          languages: languages,
          showMeaning: settings.showMeaning ?? defaultShow(),
          showTranslit: settings.showTranslit ?? defaultShow(),
          showTitles: settings.showTitles ?? defaultShow(),
          contents: contents,
          englishContents: sameAsEnglish ? contents : await repo.getContents(en),
          titles: titles,
          englishTitles: sameAsEnglish ? titles : await repo.getTitles(en),
        ),
      );
    } catch (e) {
      // A missing or broken database must never break the viewer: show Arabic only.
      hisnPrint("translations load failed: $e");
      emit(TranslationsState(isLoaded: true, setting: setting));
    }
  }
}
