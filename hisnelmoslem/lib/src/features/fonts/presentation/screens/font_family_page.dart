import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/features/fonts/data/data_source/fonts.dart';
import 'package:hisnelmoslem/src/features/themes/presentation/controller/cubit/theme_cubit.dart';

class FontFamilyPage extends StatelessWidget {
  const FontFamilyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();
    return BlocBuilder<ThemeCubit, ThemeState>(
      bloc: themeCubit,
      builder: (context, state) {
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
            children: List.generate(fontFamilies.length, (index) {
              final font = fontFamilies[index];
              return ListTile(
                key: Key('$index'),
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
                onTap: () => themeCubit.changeFontFamily(font),
              );
            }),
          ),
        );
      },
    );
  }
}
