import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/Shared/Widgets/Loading.dart';
import 'package:hisnelmoslem/shared/constants/constant.dart';

import '../../controllers/quran_controller.dart';

class QuranReadPage extends StatelessWidget {
  const QuranReadPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return  GetBuilder<QuranPageController>(
      init: QuranPageController(),
          builder: (controller) {
            return controller.isLoading
                ? Loading()
                : Scaffold(
                key: controller.quranReadPageScaffoldKey,
                appBar: AppBar(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  elevation: 0,
                  title: Text(controller.quranDisplay[0].surha,
                      style: TextStyle(fontFamily: "Uthmanic")),
                  actions: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: CircleAvatar(
                        backgroundColor: transparent,
                        child: Text('${controller.page + controller.currentPage}'),
                      ),
                    )
                  ],
                ),
                body: ScrollConfiguration(
                  behavior: ScrollBehavior(),
                  child: GlowingOverscrollIndicator(
                    axisDirection: AxisDirection.left,
                    color: black26,
                    child: PageView.builder(
                      onPageChanged: controller.onPageViewChange,
                      controller: controller.pageController,
                      itemCount: controller.quranDisplay[0].pages.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            BetweenPageEffect(index: index + 1),
                            PageSideEffect(index: index + 1),
                            Center(
                              child: ColorFiltered(
                                  colorFilter: greyScale,
                                  child: ColorFiltered(
                                      colorFilter: invert,
                                      child: Image.asset(
                                        controller.quranDisplay[0].pages[index].toString(),
                                        fit: BoxFit.fitWidth,
                                      ))),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              );
          }
        );
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
      alignment: index.isOdd ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: 50,
        decoration: new BoxDecoration(
            gradient: new LinearGradient(
          begin: index.isEven ? Alignment.centerRight : Alignment.centerLeft,
          end: index.isEven ? Alignment.centerLeft : Alignment.centerRight,
          colors: [
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
      alignment: index.isEven ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: 5,
        height: 5000,
        decoration: new BoxDecoration(
            gradient: new LinearGradient(
          begin: index.isEven ? Alignment.centerRight : Alignment.centerLeft,
          end: index.isEven ? Alignment.centerLeft : Alignment.centerRight,
          colors: [
            white,
            black.withAlpha(200),
          ],
        )),
      ),
    );
  }
}
