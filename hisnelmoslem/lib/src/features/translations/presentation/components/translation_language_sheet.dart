import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/translations/domain/translation_resolver.dart';
import 'package:hisnelmoslem/src/features/translations/presentation/controller/translations_cubit.dart';

/// Lets the user pick the translation language: automatic or one of the bundled languages,
/// each with the source of its translation.
class TranslationLanguageSheet extends StatelessWidget {
  const TranslationLanguageSheet({super.key});

  static Future<void> show(BuildContext context) {
    final cubit = context.read<TranslationsCubit>();
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const SafeArea(top: false, child: TranslationLanguageSheet()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return BlocBuilder<TranslationsCubit, TranslationsState>(
      builder: (context, state) {
        final cubit = context.read<TranslationsCubit>();
        final selected = state.languageOf(state.setting)?.code ?? TranslationResolver.auto;

        Future<void> choose(String setting) async {
          await cubit.changeLanguage(setting);
          if (context.mounted) Navigator.of(context).pop();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(s.translationLanguage, style: theme.textTheme.titleLarge),
              ),
              RadioGroup<String>(
                groupValue: selected,
                onChanged: (value) {
                  if (value != null) choose(value);
                },
                child: Column(
                  children: [
                    RadioListTile<String>(
                      value: TranslationResolver.auto,
                      title: Text(s.translationLanguageAuto),
                      subtitle: Text(s.translationLanguageAutoDesc),
                    ),
                    for (final language in state.languages)
                      RadioListTile<String>(
                        value: language.code,
                        title: Text(language.nameNative),
                        subtitle: language.source.isEmpty
                            ? null
                            : Text(s.translationSource(language.source)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
