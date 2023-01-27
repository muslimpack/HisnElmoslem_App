import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/app/data/app_data.dart';
import 'package:hisnelmoslem/app/shared/functions/open_url.dart';
import 'package:hisnelmoslem/app/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/app/shared/widgets/empty.dart';
import 'package:hisnelmoslem/app/views/dashboard/dashboard.dart';
import 'package:hisnelmoslem/core/values/constant.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class OnBoardingController extends GetxController {
  /* *************** Variables *************** */
  //
  PageController pageController = PageController();

  //
  bool get isFinalPage => currentPageIndex + 1 == pageList.length;

  // show skip button
  bool get showSkipBtn => true;

  //
  int currentPageIndex = 0;

  //
  static const _volumeBtnChannel = MethodChannel("volume_button_channel");

  //
  final pageList = [
    const Empty(
      title: "حصن المسلم الإصدار $appVersion",
      description: '''
السلام عليكم أيها الموفق 
أهلا بك في تحديث جديد من حصن المسلم
قم بسحب الشاشة لتقليب الصفحات
أو استخدم مفاتيح الصوت لرؤية الميزات الجديدة 
''',
    ),
    const Empty(
      isImage: false,
      icon: MdiIcons.volumeSource,
      title: "التحكم في مستوى صوت التأثيرات",
    ),
    const Empty(
      isImage: false,
      icon: Icons.vertical_split_rounded,
      title: "القائمة الجانبية تتغير مع تغير لغة التطبيق",
    ),
    const Empty(
      isImage: false,
      icon: Icons.watch,
      title: "حل مشكلة عداد المئة في السبحة",
    ),
    const Empty(
      isImage: false,
      icon: Icons.notifications,
      title: "حل مشكلة عدم توجه التطبيق للذكر عند الضغط على البدء من الإشعارات",
    ),
    const Empty(
      isImage: false,
      icon: MdiIcons.toolbox,
      title: "بعض التحسينات على الأداء",
    ),
    Empty(
      imagePath: "assets/images/qadaa.png",
      icon: MdiIcons.bug,
      title: "تطبيق قضاء",
      description: """
تطبيق يعينك على قضاء ما فاتك من صلوات
التطبيق مجاني وخالي من الإعلانات
- من إصداراتنا -
""",
      onButtonCLick: () => {
        openURL(
          "https://play.google.com/store/apps/details?id=com.hassaneltantawy.qadaa",
        )
      },
      buttonText: "افتح متجر بلاي",
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
