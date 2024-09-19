import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_object.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/quran/data/models/surah_name_enum.dart';
import 'package:hisnelmoslem/src/features/quran/presentation/components/between_page_effect.dart';
import 'package:hisnelmoslem/src/features/quran/presentation/components/page_side_effect.dart';
import 'package:hisnelmoslem/src/features/quran/presentation/controller/cubit/quran_cubit.dart';

class QuranReadScreen extends StatelessWidget {
  final SurahNameEnum surahName;

  const QuranReadScreen({super.key, required this.surahName});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<QuranCubit>()..start(surahName),
      child: BlocBuilder<QuranCubit, QuranState>(
        builder: (context, state) {
          if (state is! QuranLoadedState) {
            return const Loading();
          }
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              centerTitle: true,
              title: Text(
                () {
                  switch (state.surahName) {
                    case SurahNameEnum.alKahf:
                      return S.of(context).suraAlKahf;
                    case SurahNameEnum.alMulk:
                      return S.of(context).suraAlMulk;
                    case SurahNameEnum.assajdah:
                      return S.of(context).suraAsSajdah;
                    case SurahNameEnum.endofAliImran:
                      return S.of(context).endSuraAliImran;
                  }
                }(),
              ),
            ),
            body: GestureDetector(
              onDoubleTap: () => context.read<QuranCubit>().onDoubleTap(),
              child: PageView.builder(
                physics: const BouncingScrollPhysics(),
                controller: context.read<QuranCubit>().pageController,
                itemCount: state.requiredSurah.pages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      BetweenPageEffect(
                        index: state.requiredSurah.pages[index].pageNumber,
                      ),
                      PageSideEffect(
                        index: state.requiredSurah.pages[index].pageNumber,
                      ),
                      Center(
                        child: ColorFiltered(
                          colorFilter: greyScale,
                          child: ColorFiltered(
                            colorFilter:
                                Theme.of(context).brightness == Brightness.dark
                                    ? invert
                                    : normal,
                            child: Image.asset(
                              state.requiredSurah.pages[index].image,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            state.requiredSurah.pages[index].pageNumber
                                .toArabicNumberString(),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
