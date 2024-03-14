// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_object.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/round_button.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/onboarding/presentation/controller/onboarding_controller.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OnBoardingController>(
      init: OnBoardingController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text(appVersion.toArabicNumber()),
            centerTitle: true,
          ),
          body: PageView.builder(
            physics: const BouncingScrollPhysics(),
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
                        (index) => Dot(
                          index: index,
                          currentPageIndex: controller.currentPageIndex,
                        ),
                      ),
                    ),
                  ),
                  if (controller.isFinalPage)
                    Expanded(
                      child: RoundButton(
                        radius: 10,
                        text: Text(
                          'Start'.tr,
                        ),
                        onTap: () {
                          controller.goToDashboard();
                        },
                      ),
                    )
                  else
                    !controller.showSkipBtn
                        ? const SizedBox()
                        : Expanded(
                            child: RoundButton(
                              radius: 10,
                              isTransparent: true,
                              text: Text(
                                "Skip".tr,
                                style: const TextStyle(),
                              ),
                              onTap: () {
                                controller.goToDashboard();
                              },
                            ),
                          ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class Dot extends StatelessWidget {
  final int index;
  final int currentPageIndex;
  const Dot({
    super.key,
    required this.index,
    required this.currentPageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 10,
      width: currentPageIndex == index ? 25 : 10,
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
