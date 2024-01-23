import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/utils/print.dart';
import 'package:hisnelmoslem/src/features/settings/data/data_source/app_data.dart';
import 'package:hisnelmoslem/src/features/settings/presentation/components/app_language_page/app_language_page_controller.dart';

class AppLanguagePage extends StatelessWidget {
  const AppLanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppLanguagePageController>(
      init: AppLanguagePageController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              S.of(context).app_language,
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
          ),
          body: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: controller.languages.length,
            itemBuilder: (context, index) {
              hisnPrint(appData.appLocale.languageCode);
              hisnPrint(controller.languages[index].code);
              return ListTile(
                tileColor: appData.appLocale.languageCode ==
                        controller.languages[index].code
                    ? controller.activeColor
                    : null,
                title: Text(
                  controller.languages[index].display,
                ),
                subtitle: Text(
                  controller.languages[index].code,
                ),
                leading: const Icon(Icons.translate_rounded),
                onTap: () => controller
                    .changeAppLanguage(controller.languages[index].code),
              );
            },
          ),
        );
      },
    );
  }
}
