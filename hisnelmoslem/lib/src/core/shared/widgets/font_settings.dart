import 'package:flutter/material.dart';
import 'package:hisnelmoslem/src/core/extensions/string_extension.dart';
import 'package:hisnelmoslem/src/core/repos/app_data.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

/// TODO wire with setting cubit
class FontSettingsToolbox extends StatelessWidget {
  final bool showFontResizeControllers;
  final bool showDiacriticsControllers;

  const FontSettingsToolbox({
    super.key,
    this.showFontResizeControllers = true,
    this.showDiacriticsControllers = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        if (showFontResizeControllers) ...[
          IconButton(
            icon: Icon(MdiIcons.restart),
            onPressed: () {
              AppData.instance.resetFontSize();
            },
          ),
          IconButton(
            icon: Icon(MdiIcons.formatFontSizeIncrease),
            onPressed: () {
              AppData.instance.increaseFontSize();
            },
          ),
          IconButton(
            icon: Icon(MdiIcons.formatFontSizeDecrease),
            onPressed: () {
              AppData.instance.decreaseFontSize();
            },
          ),
        ],
        if (showDiacriticsControllers)
          IconButton(
            icon: Icon(MdiIcons.abjadArabic),
            onPressed: () {
              AppData.instance.toggleDiacriticsStatus();
            },
          ),
      ],
    );
  }
}

class TextSample extends StatelessWidget {
  const TextSample({super.key});
  static String text =
      "سُبْحَانَكَ اللَّهُمَّ رَبَّنَا وَبِحَمْدِكَ، اللَّهُمَّ اغْفِرْ لِي";

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Text(
              AppData.instance.isDiacriticsEnabled
                  ? text
                  : text.removeDiacritics,
              textAlign: TextAlign.center,
              softWrap: true,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: AppData.instance.fontSize * 10,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
