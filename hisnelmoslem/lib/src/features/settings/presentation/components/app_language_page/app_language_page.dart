import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
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
          body: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              for (int index = 0;
                  index < controller.languages.length;
                  index += 1)
                ListTile(
                  key: Key('$index'),
                  tileColor: Get.locale!.languageCode ==
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
                ),
            ],
          ),
        );
      },
    );
  }
}
