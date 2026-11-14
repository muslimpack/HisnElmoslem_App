import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/settings/presentation/controller/cubit/settings_cubit.dart';
import 'package:hisnelmoslem/src/features/translations/domain/translation_resolver.dart';
import 'package:hisnelmoslem/src/features/translations/domain/zikr_translation.dart';
import 'package:hisnelmoslem/src/features/translations/presentation/components/title_translation_text.dart';
import 'package:hisnelmoslem/src/features/translations/presentation/controller/translations_cubit.dart';

/// The note, transliteration and meaning of a zikr, shown under its Arabic text.
/// [contentKey] is `DbContent.translationKey`; without one nothing is shown.
class ZikrTranslationBlock extends StatelessWidget {
  final int? contentKey;

  const ZikrTranslationBlock({super.key, required this.contentKey});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationsCubit, TranslationsState>(
      builder: (context, state) {
        final translation = state.translationFor(contentKey);
        if (translation == null) return const SizedBox.shrink();
        final fontSize = context.select<SettingsCubit, double>((c) => c.state.fontSize);
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (translation.note case final note?)
                _TranslationNote(field: note, fontSize: fontSize * 5),
              if (translation.translit case final translit?)
                _TranslationTranslit(field: translit, fontSize: fontSize * 6),
              if (translation.meaning case final meaning?)
                _TranslationMeaning(
                  field: meaning,
                  fontSize: fontSize * 6.5,
                  isRtl: state.isRtl(meaning.lang),
                ),
              if (translation.coverage == TranslationCoverage.partial)
                _TranslationPartialHint(fontSize: fontSize * 4.5),
            ],
          ),
        );
      },
    );
  }
}

class _TranslationNote extends StatelessWidget {
  final ResolvedField field;
  final double fontSize;

  const _TranslationNote({required this.field, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        field.text,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        style: TextStyle(
          fontFamily: kTranslationFontFamily,
          fontSize: fontSize,
          fontStyle: FontStyle.italic,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Transliteration is Latin text: always left to right, italic, in the secondary colour.
class _TranslationTranslit extends StatelessWidget {
  final ResolvedField field;
  final double fontSize;

  const _TranslationTranslit({required this.field, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _WithLanguageBadge(
        field: field,
        child: Text(
          field.text,
          textAlign: TextAlign.start,
          textDirection: TextDirection.ltr,
          style: TextStyle(
            fontFamily: kTranslationFontFamily,
            fontSize: fontSize,
            height: 1.5,
            fontStyle: FontStyle.italic,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}

class _TranslationMeaning extends StatelessWidget {
  final ResolvedField field;
  final double fontSize;
  final bool isRtl;

  const _TranslationMeaning({required this.field, required this.fontSize, required this.isRtl});

  @override
  Widget build(BuildContext context) {
    return _WithLanguageBadge(
      field: field,
      child: Text(
        field.text,
        textAlign: TextAlign.start,
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        style: TextStyle(
          fontFamily: kTranslationFontFamily,
          fontSize: fontSize,
          height: 1.5,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

/// The text with a small "EN" badge in front when it is not in the user's language.
class _WithLanguageBadge extends StatelessWidget {
  final ResolvedField field;
  final Widget child;

  const _WithLanguageBadge({required this.field, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!field.isFallback) return child;
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      textDirection: TextDirection.ltr,
      children: [
        Tooltip(
          message: S.of(context).translationFallbackHint,
          child: Container(
            margin: const EdgeInsets.only(top: 3, right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              field.lang.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class _TranslationPartialHint extends StatelessWidget {
  final double fontSize;

  const _TranslationPartialHint({required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        S.of(context).translationPartialHint,
        style: TextStyle(
          fontSize: fontSize,
          fontStyle: FontStyle.italic,
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}
