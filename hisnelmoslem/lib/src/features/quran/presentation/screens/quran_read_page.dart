import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/quran/data/models/surah_name_enum.dart';
import 'package:hisnelmoslem/src/features/quran/presentation/components/between_page_effect.dart';
import 'package:hisnelmoslem/src/features/quran/presentation/components/page_side_effect.dart';
import 'package:hisnelmoslem/src/features/quran/presentation/controller/quran_controller.dart';

class QuranReadPage extends StatelessWidget {
  final SurahNameEnum surahName;

  const QuranReadPage({super.key, required this.surahName});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<QuranPageController>(
      init: QuranPageController(surahName: surahName),
      builder: (controller) {
        return controller.isLoading
            ? const Loading()
            : Scaffold(
                key: controller.quranReadPageScaffoldKey,
                appBar: AppBar(
                  elevation: 0,
                  centerTitle: true,
                  title: Text(
                    () {
                      switch (controller.surahName) {
                        case SurahNameEnum.alKahf:
                          return 'sura Al-Kahf'.tr;
                        case SurahNameEnum.alMulk:
                          return 'sura Al-Mulk'.tr;
                        case SurahNameEnum.assajdah:
                          return 'sura As-Sajdah'.tr;
                        case SurahNameEnum.endofAliImran:
                          return "end sura Ali 'Imran".tr;
                      }
                    }(),
                  ),
                ),
                body: GestureDetector(
                  onDoubleTap: () => controller.onDoubleTap(),
                  child: PageView.builder(
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: controller.onPageViewChange,
                    controller: controller.pageController,
                    itemCount: controller.quranRequiredSurah!.pages.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          BetweenPageEffect(
                            index: controller
                                .quranRequiredSurah!.pages[index].pageNumber,
                          ),
                          PageSideEffect(
                            index: controller
                                .quranRequiredSurah!.pages[index].pageNumber,
                          ),
                          Center(
                            child: ColorFiltered(
                              colorFilter: greyScale,
                              child: ColorFiltered(
                                colorFilter: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? invert
                                    : normal,
                                child: Image.asset(
                                  controller
                                      .quranRequiredSurah!.pages[index].image,
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
                                '${controller.quranRequiredSurah!.pages[index].pageNumber}',
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
    );
  }
}
