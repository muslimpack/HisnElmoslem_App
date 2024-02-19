import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/features/fonts/presentation/screens/font_family_page_controller.dart';

class FontFamilyPage extends StatelessWidget {
  const FontFamilyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FontFamilyPageController>(
      init: FontFamilyPageController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              "font type".tr,
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              for (int index = 0;
                  index < controller.fontFamilies.length;
                  index += 1)
                ListTile(
                  key: Key('$index'),
                  tileColor:
                      controller.activeFont == controller.fontFamilies[index]
                          ? controller.activeColor
                          : null,
                  subtitle: Text(
                    controller.fontFamilies[index],
                    style: TextStyle(
                      fontFamily: controller.fontFamilies[index],
                    ),
                  ),
                  title: Text(
                    "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ سُبْحَانَ اللَّهِ الْعَظِيمِ",
                    style: TextStyle(
                      fontFamily: controller.fontFamilies[index],
                    ),
                  ),
                  leading: const Icon(Icons.text_format),
                  onTap: () => controller
                      .changeFontFamily(controller.fontFamilies[index]),
                ),
            ],
          ),
        );
      },
    );
  }
}
