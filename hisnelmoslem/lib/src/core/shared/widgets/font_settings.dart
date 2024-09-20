import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/extensions/string_extension.dart';
import 'package:hisnelmoslem/src/features/settings/presentation/controller/cubit/settings_cubit.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class FontSettingsToolbox extends StatelessWidget {
  const FontSettingsToolbox({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        TextSample(),
        FontSettingsBar(),
      ],
    );
  }
}

class FontSettingsBar extends StatelessWidget {
  final bool showFontResizeControllers;
  final bool showDiacriticsControllers;

  const FontSettingsBar({
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
            tooltip: S.of(context).fontResetSize,
            icon: Icon(MdiIcons.restart),
            onPressed: () {
              context.read<SettingsCubit>().resetFontSize();
            },
          ),
          IconButton(
            tooltip: S.of(context).fontIncreaeSize,
            icon: Icon(MdiIcons.formatFontSizeIncrease),
            onPressed: () {
              context.read<SettingsCubit>().increaseFontSize();
            },
          ),
          IconButton(
            tooltip: S.of(context).fontDecreaeSize,
            icon: Icon(MdiIcons.formatFontSizeDecrease),
            onPressed: () {
              context.read<SettingsCubit>().decreaseFontSize();
            },
          ),
        ],
        if (showDiacriticsControllers)
          IconButton(
            tooltip: S.of(context).showDiacritics,
            icon: Transform.rotate(
              angle: context.watch<SettingsCubit>().state.showDiacritics
                  ? 0
                  : -math.pi / 8,
              child: Icon(
                MdiIcons.abjadArabic,
                size: context.watch<SettingsCubit>().state.showDiacritics
                    ? 30
                    : 25,
              ),
            ),
            onPressed: () {
              context.read<SettingsCubit>().toggleDiacriticsStatus();
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
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return SizedBox(
          height: 200,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Center(
                child: Text(
                  state.showDiacritics ? text : text.removeDiacritics,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: state.fontSize * 10,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
