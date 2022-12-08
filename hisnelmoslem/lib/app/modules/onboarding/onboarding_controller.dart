import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/app/data/app_data.dart';
import 'package:hisnelmoslem/app/shared/functions/open_url.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../shared/transition_animation/transition_animation.dart';
import '../../shared/widgets/empty.dart';
import '../../views/dashboard/dashboard.dart';

class OnBoardingController extends GetxController {
  /* *************** Variables *************** */
  //
  PageController pageController = PageController(initialPage: 0);

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
      title: "حصن المسلم الإصدار 2.2.1",
      description: '''
عدنا إليك أيها الكريم بتحديث جديد من حصن المسلم
قم بتقليب الصفحات
أو استخدم مفاتيح الصوت لرؤية الميزات الجديدة 
''',
    ),
    const Empty(
      isImage: false,
      icon: Icons.font_download,
      title: "15 نوعا من الخط",
      description: """
الآن يمكنك تبديل الخط داخل التطبيق والاختيار من بين 15 خطا حسب رغبتك
من الاعدادات ادخل على نوع الخط ثم اضغط على الخط الذي تريده
""",
    ),
    const Empty(
      isImage: false,
      icon: Icons.share,
      title: "الخط يظهر عند مشاركة الذكر كصورة",
      description: """
""",
    ),
    const Empty(
      isImage: false,
      icon: Icons.notifications,
      title: "حل مشاكل خاصة بالاشعارات",
      description: """
اصلاح مشكلة تأخر الاشعارات المجدولة مدة يوم عن موعدها""",
    ),
    const Empty(
      isImage: false,
      icon: Icons.bug_report,
      title: "حل بعض المشكلات",
      description:
          "حل مشكلة عدم ظهور شريط الأدوات والأزار في النوافذ واختفاءها أسفل أزرار التنقل في بعض الهواتف",
    ),
    const Empty(
      isImage: false,
      icon: Icons.android,
      title: "حل بعض المشكلات",
      description: "حل مشكلة ظهور شاشة سوداء عند مستخدمي أندرويد 13",
    ),
    const Empty(
      isImage: false,
      icon: Icons.mail,
      title: "حل بعض المشكلات",
      description: "حل مشكلة إرسال بريد بالأخطاء وخلافه",
    ),
    Empty(
      isImage: true,
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
            "https://play.google.com/store/apps/details?id=com.hassaneltantawy.qadaa")
      },
      buttonText: "افتح متجر بلاي",
    ),
  ];

  /* *************** Controller life cycle *************** */
  //
  @override
  void onInit() async {
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

      return Future.value(null);
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
  goToDashboard() {
    appData.changIsFirstOpenToThisRelease(false);
    transitionAnimation.circleRevalPushReplacement(
        context: Get.context!, goToPage: const AzkarDashboard());
  }
}
