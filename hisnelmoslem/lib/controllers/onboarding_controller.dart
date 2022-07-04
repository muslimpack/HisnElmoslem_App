import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/controllers/app_data_controllers.dart';
import 'package:hisnelmoslem/shared/functions/open_url.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../shared/transition_animation/transition_animation.dart';
import '../shared/widgets/empty.dart';
import '../views/dashboard/dashboard.dart';

class OnBoardingController extends GetxController {
  /* *************** Variables *************** */
  //
  PageController pageController = PageController(initialPage: 0);

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
    const Empty(
      title: "حصن المسلم الإصدار 2.1.0",
      description: '''
أهلا بك أيها الموفق في هذا الإصدار الجديد من تطبيق حصن المسلم 
قم بتقليب الصفحات
أو استخدم مفاتيح الصوت لرؤية الميزات الجديدة 
''',
    ),
    const Empty(
      isImage: false,
      icon: Icons.imagesearch_roller_sharp,
      title: "إمكانية ترتيب النوافذ على الواجهة",
      description: """
يمكنك الآن ترتيب الصفحات على الشاشة الرئيسية كما تحب
قم بالذهاب للإعدادات ثم اختر ترتيب الشاشة
ثم اضغط على الشاشة ضغطة مطولة ثم قم بالسحب
""",
    ),
    const Empty(
      isImage: false,
      icon: Icons.nightlight,
      title: "إضافة ذكر أستغفر الله وأتوب إليه في أذكار المساء",
      description: """
بعد مراجعة التقييمات التي وصلتنا على البريد تبين عدم وجود ذكر في أذكار المساء لذا قمنا بإضافته
""",
    ),
    const Empty(
      isImage: false,
      icon: Icons.restart_alt,
      title: "إمكانية إعادة تعيين العداد في بطاقات الذكر المفضل",
      description: "",
    ),
    const Empty(
      isImage: false,
      icon: Icons.notifications,
      title: "إعادة كتابة الإشعارات",
      description: "",
    ),
    const Empty(
      isImage: false,
      icon: Icons.star_border_purple500_rounded,
      title: "تحسينات في واجهة التطبيق",
      description: """
- تحسين صفحة تاريخ الميزات
- تحسين في القائمة الجانبية في الشاشة الرئيسية
- تحسين في شكل حالة التنبيهات على الواجهة
- تحسين في شكل إضافة وتعديل التنبيهات
- تحسين في بطاقات التنبيهات في إدارة التنبيهات
""",
    ),
    const Empty(
      isImage: false,
      icon: Icons.bug_report_outlined,
      title: "حل المشاكل التي وصلتنا",
      description: """
- حفظ ثيم التطبيق عند أول مرة لفتحة وجعل الوضع المعتم هو الوضع الإفتراضي للتطبيق
- حل مشكلة عدم تحديث معاينة الخط في الإعدادات
- حل مشكلة اللون الأبيض عند فتح البرنامج
- حل مشكلة ظهور التنبيهات بعد حذفها
""",
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
