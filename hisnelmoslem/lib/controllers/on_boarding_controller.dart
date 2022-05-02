import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../shared/transition_animation/transition_animation.dart';
import '../shared/widgets/empty.dart';
import '../views/screens/dashboard.dart';

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
      title: "حصن المسلم الإصدار 1.8.0",
      description: '''
أهلا بك أيها الكريم في هذا الإصدار الجديد من حصن المسلم 
قم بتقليب الصفحات لرؤية الميزات الجديدة 
أو اضغط على تخط
''',
    ),
    const Empty(
      isImage: false,
      icon: Icons.watch_rounded,
      title: "تطوير السبحة",
      description: """
- اضافة ذكر والتسبيح لكل ذكر بشكل منفرد
- امكانية ضبط العداد من 33 لأي عدد تشاء
- لا تقلق سيتم الاحتفاظ بتقدمك القديم تحت مسمى عام في التسبيحات
- لتفعيل ذكر معين اضغط على علامة العداد بجانبه
""",
    ),
    const Empty(
      isImage: false,
      icon: MdiIcons.bookOpenPageVariant,
      title: "اضافة سورة الملك براوية حفص عن عاصم",
    ),
    const Empty(
      isImage: false,
      icon: MdiIcons.viewDashboard,
      title: "تطوير شكل الواجهة وجعلها أكثر بساطة",
    ),
    const Empty(
      isImage: false,
      icon: Icons.bug_report_sharp,
      title: "إصلاح بعض واجهات الصفحات",
    ),
    const Empty(
      isImage: false,
      icon: Icons.notifications,
      title: "كيفية التواصل في حالة وجود مشكلة؟",
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
  }

  /* *************** Functions *************** */
  /// Go to dashboard
  /// and set app fisrt open to false
  goToDashboard() {
    final box = GetStorage();
    box.write("is_v1.8_first_open", false);
    transitionAnimation.circleRevalPushReplacement(
        context: Get.context!, goToPage: const AzkarDashboard());
  }
}
