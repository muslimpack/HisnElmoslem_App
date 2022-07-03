import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/Shared/Widgets/loading.dart';
import 'package:hisnelmoslem/shared/constants/constant.dart';
import 'package:hisnelmoslem/shared/widgets/scroll_glow_custom.dart';
import 'package:hisnelmoslem/themes/theme_services.dart';

import '../../controllers/quran_controller.dart';

class QuranReadPage extends StatelessWidget {
  final SurahNameEnum surahName;

  const QuranReadPage({
    Key? key,
    required this.surahName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<QuranPageController>(
        init: QuranPageController(surahName: surahName),
        builder: (controller) {
          return controller.isLoading
              ? const Loading()
              : Scaffold(
                  key: controller.quranReadPageScaffoldKey,
                  body: ScrollGlowCustom(
                    axisDirection: AxisDirection.left,
                    child: GestureDetector(
                      onDoubleTap: () {
                        controller.onDoubleTap();
                      },
                      child: PageView.builder(
                        onPageChanged: controller.onPageViewChange,
                        controller: controller.pageController,
                        itemCount: controller.quranRequiredSurah!.pages.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              BetweenPageEffect(
                                  index: controller.quranRequiredSurah!
                                      .pages[index].pageNumber),
                              PageSideEffect(
                                  index: controller.quranRequiredSurah!
                                      .pages[index].pageNumber),
                              Center(
                                child: ColorFiltered(
                                    colorFilter: greyScale,
                                    child: ColorFiltered(
                                        colorFilter: ThemeServices.isDarkMode()
                                            ? invert
                                            : normal,
                                        child: Image.asset(
                                          controller.quranRequiredSurah!
                                              .pages[index].image,
                                          fit: BoxFit.fitWidth,
                                        ))),
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
                              Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                      "سورة ${controller.quranRequiredSurah!.surah}",
                                      style: const TextStyle(
                                          fontFamily: "Uthmanic")),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: IconButton(
                                  onPressed: () {
                                    controller.toggleTheme();
                                  },
                                  icon: const Icon(Icons.dark_mode),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                );
        });
  }
}

class BetweenPageEffect extends StatelessWidget {
  final int index;

  const BetweenPageEffect({
    Key? key,
    required this.index,
  }) : super(key: key);

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
            transparent,
            black.withOpacity(.05),
            black.withOpacity(.1),
          ],
        )),
      ),
    );
  }
}

class PageSideEffect extends StatelessWidget {
  final int index;

  const PageSideEffect({
    Key? key,
    required this.index,
  }) : super(key: key);

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
            white,
            black.withAlpha(200),
          ],
        )),
      ),
    );
  }
}
