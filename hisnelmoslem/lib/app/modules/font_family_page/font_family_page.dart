import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/app/shared/widgets/scroll_glow_custom.dart';

import 'font_family_page_controller.dart';

class FontFamilyPage extends StatelessWidget {
  const FontFamilyPage({super.key})  ;

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
            body: ScrollGlowCustom(
              child: ListView(
                children: [
                  for (int index = 0;
                      index < controller.fontFamiles.length;
                      index += 1)
                    ListTile(
                      key: Key('$index'),
                      tileColor:
                          controller.activeFont == controller.fontFamiles[index]
                              ? controller.activeColor
                              : null,
                      subtitle: Text(
                        controller.fontFamiles[index],
                        style: TextStyle(
                            fontFamily: controller.fontFamiles[index]),
                      ),
                      title: Text(
                        "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ سُبْحَانَ اللَّهِ الْعَظِيمِ",
                        style: TextStyle(
                            fontFamily: controller.fontFamiles[index]),
                      ),
                      leading: const Icon(Icons.text_format),
                      onTap: () => controller
                          .changeFontFamily(controller.fontFamiles[index]),
                    ),
                ],
              ),
            ),
          );
        });
  }
}
