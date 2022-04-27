import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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
      title: "حصن المسلم الإصدار 1.7.0",
      description: '''
أهلا بك أيها الكريم في هذا اللإصدار الجديد من حصن المسلم 
قم بتقليب الصفحات لرؤية الميزات الجديدة 
أو اضغط على تخط
''',
    ),
    const Empty(
      isImage: false,
      icon: Icons.speaker_group,
      title: "مؤثرات صوتية",
      description: """
- اضافة مؤثرات صوتية عند
- الضغط للتسبيح
- عند اكتمال الذكر
- عند اكتمال جميع الأذكار

بشكل افتراضي جميع المؤثرات مغلقة اذهب للإعدادات ومن ثم إدراة مؤثرات الصوت لتفعيلها
""",
    ),
    const Empty(
      isImage: false,
      icon: Icons.dark_mode,
      title: "عودة الوضع المعتم القديم",
      description: """
- عودة الوضع المعتم القديم للتطبيق ليصبح هناك ثلاثة أوضاع
- وضع فاتح
- وضع معتم
- وضع معتم محسن

اذهب للإعدادات ومن ثم إدراة ألوان التطبيق
""",
    ),
    const Empty(
      isImage: false,
      icon: Icons.bug_report_sharp,
      title: "إصلاح بعض المشاكل",
      description: """
- إصلاح بعض المشاكل واضافة بعض التحسينات على التطبيقات
""",
    ),
    const Empty(
      isImage: false,
      icon: Icons.notifications,
      title: "كيفية التواصل في حالة وجود مشكلة؟",
      description: """
إذا واجهتك مشكلة بالتطبيق أو لديك فكرة لميزة يمكن اضافتها للتطبيق

اذهب للإعدادات ومن ثم اضغط على الشكاوى والمقترحات وأجب عن الأسئلة وأرسلها لي
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
    box.write("is_v1.7_first_open", false);
    transitionAnimation.circleRevalPushReplacement(
        context: Get.context!, goToPage: const AzkarDashboard());
  }
}
