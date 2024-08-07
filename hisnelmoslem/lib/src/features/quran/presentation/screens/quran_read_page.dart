import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
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
                  // actions: [
                  //   IconButton(
                  //     onPressed: () => controller.toggleTheme(),
                  //     icon: const Icon(Icons.dark_mode),
                  //   ),
                  // ],
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

class BetweenPageEffect extends StatelessWidget {
  final int index;

  const BetweenPageEffect({
    super.key,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: index.isEven ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: index.isOdd ? Alignment.centerRight : Alignment.centerLeft,
            end: index.isOdd ? Alignment.centerLeft : Alignment.centerRight,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(.05),
              Colors.black.withOpacity(.1),
            ],
          ),
        ),
      ),
    );
  }
}

class PageSideEffect extends StatelessWidget {
  final int index;

  const PageSideEffect({
    super.key,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: index.isOdd ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: 5,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: index.isOdd ? Alignment.centerRight : Alignment.centerLeft,
            end: index.isOdd ? Alignment.centerLeft : Alignment.centerRight,
            colors: [
              Colors.white,
              Colors.black.withAlpha(200),
            ],
          ),
        ),
      ),
    );
  }
}
