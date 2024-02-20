import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/repos/app_data.dart';
import 'package:hisnelmoslem/src/core/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/empty.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
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
    const Empty(
      title: "حصن المسلم الإصدار $appVersion",
      description: '''
السلام عليكم أيها الكريم 
أهلا بك في تحديث جديد من حصن المسلم
قم بسحب الشاشة لتقليب الصفحات
أو استخدم مفاتيح الصوت لرؤية الميزات الجديدة 
''',
    ),
    const Empty(
      title: "تحديث على قاعدة البيانات",
      isImage: false,
      icon: FontAwesomeIcons.database,
      description: '''
  - فصل الأذكار المدمجة عن بعضها
  - إضافة نص الآيات داخل الذكر
''',
    ),
    const Empty(
      title: "تحسين مظهر التطبيق",
      isImage: false,
      icon: FontAwesomeIcons.palette,
      description: '''
تحسينات في مظهر التطبيق وامكانية التحكم الكامل فيه
الإعدادات > إدارة ألوان التطبيق

- لون التطبيق
- الوضع المظلم أو الفاتح
- استخدام material3
- استخدام الوضع القديم للثيمات
- تفعيل تحديد لون للخلفية مناسب للشاشات AMOLED لتوفير الطاقة عند استخدام اللون الأسود
''',
    ),
    const Empty(
      title: "إزالة تحديد الذكر بالأزرق عند تمامه",
      isImage: false,
      icon: FontAwesomeIcons.palette,
    ),
    const Empty(
      title: "إزالة وميض الشاشة عند الضغط عليها",
      isImage: false,
      icon: FontAwesomeIcons.palette,
    ),
    const Empty(
      title: "تعميم نوع الخط",
      isImage: false,
      icon: FontAwesomeIcons.font,
      description: '''
تعميم نوع الخط على التطبيق عدا الأذكار التي تحتوى آيات
''',
    ),
    const Empty(
      title: "تصويب الأخطاء التي وصلتنا",
      isImage: false,
      icon: Icons.bug_report,
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
