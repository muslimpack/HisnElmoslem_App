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
    Empty(
      title: "حصن المسلم الإصدار 1.5.0",
      description: '''
أهلا بك أيها الكريم في هذا اللإصدار الجديد من حصن المسلم 
قم بتقليب الصفحات لرؤية الميزات الجديدة 
أو اضغط على تخط
''',
    ),
    Empty(
      isImage: false,
      icon: MdiIcons.phoneRotatePortrait,
      title: "التطبيق دائما في الوضع الرأسي",
      description: """
التطبيق الآن لا يستدير مع دوران الهاتف وإنما يحافظ على الوضع الرأسي
""",
    ),
    Empty(
      isImage: false,
      icon: MdiIcons.soundbar,
      title: "التسبح بمفاتيح الصوت",
      description: """
- Stable التسبيح بمفاتيح الصوت وسماعات الرأس التي تدعم التحكم بمفاتيح الصوت
  - التحكم في الأذكار اليومية بمفاتيح الصوت
  - التحكم بالسبحة بمفاتيح الصوت
  - تقليب صفحات سورة الكهف
- كما يمكنك تصفح هذه التحديثات بمفاتيح الصوت
""",
    ),
    Empty(
      isImage: false,
      icon: MdiIcons.camera,
      title: "مشاركة الذكر كصورة",
      description: """
يمكنك الآن مشاركة الذكر على وسائل التواصل وغيرها
وضعين للألوان داكن وفاتج
تحديد امكانية مشاركة المصدر أو الفضل إن ذكر أو لا
""",
    ),
    Empty(
      isImage: false,
      icon: Icons.favorite,
      title: "اضافة أذكار إلى مفضلة الأذكار",
      description: '''
اضافة أي ذكر داخلي إلى مفضلة الأذكار للعودة إليه مباشرة في أي وقت من الصفحة الرئيسية
''',
    ),
    Empty(
      isImage: false,
      icon: Icons.alarm,
      title: "حالة التنبيهات",
      description: """
اضافة أيقوانات لمعرفة حالة المنبه
منبه فعال - منبه غير فعال - لايوجد منبه
كل هذا من الواجهة الرئيسية مباشرة
""",
    ),
    Empty(
      isImage: false,
      icon: MdiIcons.toolbox,
      title: "إعدادت الخط",
      description: """
اضافة اعدادت الخط إلى صفحة الإعدادت
يمكنك تكبير وتصغير وإعادة ضبط حجم الخط
تشغيل وايقاف تشكيل الكلمات
كل هذا مع معاينة مباشرة

""",
    ),
    Empty(
      isImage: false,
      icon: MdiIcons.square,
      title: "شريط التقدم الكلي",
      description: """
الآن شريط التقدم الكلي في وضع البطاقات
""",
    ),
    Empty(
      isImage: false,
      title: "وغيره المزيد",
      description: """
- الشريط العلوي يختفي أثناء تصفح الفهرس والمفضلة
- تعديل واجهة قراءة الأذكار في وضع الصفحات
- تعيين الحديث كمقروء
- اصلاح الألوان الساطعة في صفحة المنبهات
- اصلاح النمط لبعض النصوص
- اصلاح بعض الأخطاء
""",
    ),
    Empty(
      isImage: false,
      icon: Icons.warning_amber_rounded,
      title: "تنبيه هام",
      description: """
سيتم حذ جميع التنبيهات التي قمت بوضعها سابقا
كما سيتم حذف الأذكار التي تم وضعها في المفضلة
وجميع الإعدادات التي قمت بتعيينها في وقت سابق
""",
    )
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
            duration: Duration(milliseconds: 500),
            curve: Curves.easeIn,
          );
        }
        if (call.arguments == "VOLUME_UP_UP") {
          pageController.previousPage(
            duration: Duration(milliseconds: 500),
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
    box.write("is_v1.5_first_open", false);
    transitionAnimation.circleRevalPushReplacement(
        context: Get.context!, goToPage: AzkarDashboard());
  }
}
