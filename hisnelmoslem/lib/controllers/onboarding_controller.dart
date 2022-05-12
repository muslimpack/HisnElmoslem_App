import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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
  //
  int currentPageIndex = 0;
  //
  static const _volumeBtnChannel = MethodChannel("volume_button_channel");
  //
  final pageList = [
    const Empty(
      title: "حصن المسلم الإصدار 1.9.0",
      description: '''
أهلا بك أيها الكريم في هذا الإصدار الجديد من حصن المسلم 
قم بتقليب الصفحات لرؤية الميزات الجديدة 
أو اضغط على تخط
''',
    ),
    const Empty(
      isImage: false,
      icon: Icons.camera_alt,
      title: "تطوير كلي لمشاركة الذكر بالصورة",
      description: """
- التحكم بكل لون على حدة
[لون العنوان - لون النص - لون ملحقات النص - لون البطاقة]
- التحكم في حجم النص
- تحسين جودة الصورة لضعف الجودة السابقة وامكانية التحكم بالجودة
[1.0 - 1.5 - 2.0 - 2.5 - 3.0]
- التحكم في عرض الصورة
- التحكم في اظهار رقم الذكر أعلى الصورة
- الابقاء على الوضع القديم من حيث حجم الخط تحت مسمى "حجم خط ثابت"
- حفظ جميع الإعدادات للمرات القادمة
""",
    ),
    const Empty(
      isImage: false,
      icon: MdiIcons.palette,
      title: "اضافة وضع ألوان فاتح مائل للصفرة",
      description: """
قم بالضغط على علامة الهلال في القائمة الرئيسية للتبديل بين الأوضاع

أو قم بزيارة الإعدادات ثم اضغط على إدارة ألوان التطبيق

** الألوان مقتبسة من تطبيق آية **
""",
    ),
    const Empty(
      isImage: true,
      imagePath: "assets/images/theme_yellow_overview.png",
    ),
    const Empty(
      isImage: false,
      icon: Icons.bug_report_sharp,
      title: "إصلاح مشكلة استمرار العداد بعد الخروج من الصفحة",
    ),
    const Empty(
      isImage: false,
      icon: Icons.notifications,
      title: "كيفية التواصل في حالة وجود مشكلة أو فكرة للتطبيق؟",
      description: """
إذا واجهتك مشكلة بالتطبيق أو لديك فكرة لميزة يمكن اضافتها للتطبيق

اذهب للإعدادات ومن ثم اضغط على الشكاوى والمقترحات وأجب عن الأسئلة وأرسلها لنا
""",
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
    final box = GetStorage();
    box.write("is_v1.9_first_open", false);
    transitionAnimation.circleRevalPushReplacement(
        context: Get.context!, goToPage: const AzkarDashboard());
  }
}
