import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/controllers/on_boarding_controller.dart';
import 'package:hisnelmoslem/shared/constants/constant.dart';
import 'package:hisnelmoslem/shared/widgets/round_button.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({Key? key}) : super(key: key);

  static Container buildDot(int index, int currentPageIndex) {
    return Container(
      height: 10,
      width: currentPageIndex == index ? 25 : 10,
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: MAINCOLOR,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OnBoardingController>(
        init: OnBoardingController(),
        builder: (controller) {
          return Scaffold(
            body: PageView.builder(
              controller: controller.pageController,
              itemCount: controller.pageList.length,
              itemBuilder: (context, index) {
                return controller.pageList[index];
              },
              onPageChanged: (index) {
                controller.currentPageIndex = index;
                controller.update();
              },
            ),
            bottomNavigationBar: BottomAppBar(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Container(
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            controller.pageList.length,
                            (index) => buildDot(
                              index,
                              controller.currentPageIndex,
                            ),
                          ),
                        ),
                      ),
                    ),
                    controller.isFinalPage
                        ? Expanded(
                            child: RoundButton(
                            radius: 10,
                            text: Text(
                              "بدء",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onTap: () {
                              controller.goToDashboard();
                            },
                          ))
                        : Expanded(
                            child: RoundButton(
                            radius: 10,
                            isTransparent: true,
                            text: Text(
                              "تخط",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onTap: () {
                              controller.goToDashboard();
                            },
                          )),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
