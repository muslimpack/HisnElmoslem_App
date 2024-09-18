import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/features/fonts/data/data_source/fonts.dart';
import 'package:hisnelmoslem/src/features/themes/presentation/controller/cubit/theme_cubit.dart';

class FontFamilyPage extends StatelessWidget {
  const FontFamilyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              S.of(context).fontType,
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
          ),
          body: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: fontFamilies.length,
            itemBuilder: (context, index) {
              final font = fontFamilies[index];
              return ListTile(
                tileColor: state.fontFamily == font
                    ? Theme.of(context).colorScheme.primary.withOpacity(.2)
                    : null,
                subtitle: Text(
                  font,
                  style: TextStyle(
                    fontFamily: font,
                  ),
                ),
                title: Text(
                  "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ سُبْحَانَ اللَّهِ الْعَظِيمِ",
                  style: TextStyle(
                    fontFamily: font,
                  ),
                ),
                leading: const Icon(Icons.text_format),
                onTap: () => context.read<ThemeCubit>().changeFontFamily(font),
              );
            },
          ),
        );
      },
    );
  }
}
