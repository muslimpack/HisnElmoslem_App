import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/app/modules/onboarding/onboarding_controller.dart';
import 'package:hisnelmoslem/app/shared/widgets/round_button.dart';
import 'package:hisnelmoslem/app/shared/widgets/scroll_glow_custom.dart';
import 'package:hisnelmoslem/core/values/constant.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({super.key});

  static Container buildDot(int index, int currentPageIndex) {
    return Container(
      height: 10,
      width: currentPageIndex == index ? 25 : 10,
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: mainColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OnBoardingController>(
        init: OnBoardingController(),
        builder: (controller) {
          return Scaffold(
            body: ScrollGlowCustom(
              axisDirection: AxisDirection.left,
              child: PageView.builder(
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
            ),
            bottomNavigationBar: BottomAppBar(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: SizedBox(
                height: 50,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
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
                    controller.isFinalPage
                        ? Expanded(
                            child: RoundButton(
                            radius: 10,
                            text: Text(
                              'Start'.tr,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onTap: () {
                              controller.goToDashboard();
                            },
                          ))
                        : !controller.showSkipBtn
                            ? const SizedBox()
                            : Expanded(
                                child: RoundButton(
                                radius: 10,
                                isTransparent: true,
                                text: Text(
                                  "Skip".tr,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
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
