// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/settings/data/models/translation_data.dart';
import 'package:hisnelmoslem/src/features/themes/presentation/controller/cubit/theme_cubit.dart';

class AppLanguagePage extends StatelessWidget {
  const AppLanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              "app language".tr,
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
          ),
          body: ListView.builder(
            itemCount: kAppLanguages.length,
            itemBuilder: (context, index) {
              final TranslationData translationData = kAppLanguages[index];
              hisnPrint("${state.locale.languageCode} ${translationData.code}");
              return _LanguageCard(
                isActive: state.locale.languageCode == translationData.code,
                translationData: translationData,
              );
            },
          ),
        );
      },
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final TranslationData translationData;
  final bool isActive;
  const _LanguageCard({
    required this.translationData,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: isActive
          ? Theme.of(context).colorScheme.primary.withOpacity(.2)
          : null,
      title: Text(
        translationData.display,
      ),
      subtitle: Text(
        translationData.code,
      ),
      leading: const Icon(Icons.translate_rounded),
      onTap: () =>
          context.read<ThemeCubit>().changeAppLocale(translationData.code),
    );
  }
}
