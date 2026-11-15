import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/localization/domain/app_language.dart';
import 'package:hisnelmoslem/src/features/themes/presentation/controller/cubit/theme_cubit.dart';
import 'package:hisnelmoslem/src/features/translations/presentation/controller/translations_cubit.dart';

class AppLanguageScreen extends StatelessWidget {
  const AppLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final selectedCode = state.locale?.languageCode;
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(S.of(context).appLanguage),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: AppLanguages.all.length,
            itemBuilder: (context, index) {
              final language = AppLanguages.all[index];
              return AppLanguageTile(
                language: language,
                selected: language.code == selectedCode,
                onTap: () {
                  final translations = context.read<TranslationsCubit>();
                  context
                      .read<ThemeCubit>()
                      .changeAppLocale(language.code)
                      .then((_) => translations.refresh());
                },
              );
            },
          ),
        );
      },
    );
  }
}

/// One language row: its native name, written in its own direction, and its code underneath.
class AppLanguageTile extends StatelessWidget {
  final AppLanguage language;
  final bool selected;
  final VoidCallback onTap;

  const AppLanguageTile({
    required this.language,
    required this.selected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      selected: selected,
      tileColor: selected ? scheme.primary.withAlpha((.5 * 255).round()) : null,
      title: Text(
        language.nativeName,
        textDirection: language.isRtl ? TextDirection.rtl : TextDirection.ltr,
      ),
      subtitle: Text(language.code, textDirection: TextDirection.ltr),
      trailing: selected ? const Icon(Icons.check) : null,
      onTap: onTap,
    );
  }
}
