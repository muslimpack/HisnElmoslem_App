import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/repos/app_data.dart';
import 'package:hisnelmoslem/src/core/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/empty.dart';
import 'package:hisnelmoslem/src/features/home/presentation/screens/dashboard.dart';

class OnBoardingController extends GetxController {
  /* *************** Variables *************** */
  //
  PageController pageController = PageController();

  //
  bool get isFinalPage => currentPageIndex + 1 == pageList.length;

  // show skip button
  bool get showSkipBtn => false;

  //
  int currentPageIndex = 0;

  //
  static const _volumeBtnChannel = MethodChannel("volume_button_channel");

  //
  final pageList = [
//     const Empty(
//       title: "حصن المسلم الإصدار $appVersion",
//       description: '''
// السلام عليكم أيها المبارك
// أهلا بك في تحديث جديد من حصن المسلم
// قم بسحب الشاشة لتقليب الصفحات
// أو استخدم مفاتيح الصوت لرؤية الميزات الجديدة
// ''',
//     ),
    const Empty(
      title: "حل بعض المشكلات العاجلة",
      isImage: false,
      icon: Icons.bug_report_sharp,
      description: """
- حل مشكلة اختفاء الآيات في الوضع الفاتح
- حل مشكلة نسخ الأذكار التي تحتوي على نص قرآني
""",
    ),
  ];

  /* *************** Controller life cycle *************** */
  //
  @override
  Future<void> onInit() async {
    super.onInit();
    //
    _volumeBtnChannel.setMethodCallHandler((call) {
      if (call.method == "volumeBtnPressed") {
        if (call.arguments == "VOLUME_DOWN_UP") {
          pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeIn,
          );
        }
        if (call.arguments == "VOLUME_UP_UP") {
          pageController.previousPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeIn,
          );
        }
      }

      return Future.value();
    });
  }

  @override
  void onClose() {
    super.onClose();
    //
    pageController.dispose();

    ///
    _volumeBtnChannel.setMethodCallHandler(null);
  }

  /* *************** Functions *************** */

  /// Go to dashboard
  /// and set app fisrt open to false
  void goToDashboard() {
    appData.changIsFirstOpenToThisRelease(value: false);
    transitionAnimation.circleRevalPushReplacement(
      context: Get.context!,
      goToPage: const AzkarDashboard(),
    );
  }
}
