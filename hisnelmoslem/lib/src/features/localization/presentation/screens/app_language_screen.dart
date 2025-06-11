// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/themes/presentation/controller/cubit/theme_cubit.dart';

class AppLanguageScreen extends StatelessWidget {
  const AppLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        const supportedLocales = S.supportedLocales;
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(S.of(context).appLanguage),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: supportedLocales.length,
            itemBuilder: (context, index) {
              final currentLocale = supportedLocales[index];
              return ListTile(
                tileColor:
                    context.read<ThemeCubit>().state.locale == currentLocale
                    ? Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha((.5 * 255).round())
                    : null,
                title: Text(currentLocale.languageCode),
                onTap: () {
                  context.read<ThemeCubit>().changeAppLocale(
                    currentLocale.languageCode,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
