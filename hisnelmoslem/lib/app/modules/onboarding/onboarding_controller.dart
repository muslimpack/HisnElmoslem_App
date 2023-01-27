import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/app/data/app_data.dart';
import 'package:hisnelmoslem/app/shared/functions/open_url.dart';
import 'package:hisnelmoslem/app/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/app/shared/widgets/empty.dart';
import 'package:hisnelmoslem/app/views/dashboard/dashboard.dart';
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
      title: "حصن المسلم الإصدار 2.3.0",
      description: '''
السلام عليكم أيها الموفق 
أهلا بك في تحديث جديد من حصن المسلم
قم بسحب الشاشة لتقليب الصفحات
أو استخدم مفاتيح الصوت لرؤية الميزات الجديدة 
''',
    ),
    const Empty(
      isImage: false,
      icon: MdiIcons.comment,
      title: "إضافة شرح للأذكار",
      description: """
شرح للأذكار يتضمن الحديث والفوائد والشرح لكل ذكر من الأذكار""",
    ),
    const Empty(
      isImage: false,
      icon: Icons.palette,
      title: "أسود غريب",
      description: """
وضع جديد لألوان التطبيق "أسود غريب"
من الاعدادات إدارة ألوان التطبيق""",
    ),
    const Empty(
      isImage: false,
      icon: Icons.translate,
      title: "ترجمة الواجهة للإنجليزية",
      description: """
اضافة ترجمة انجليزية للواجهة
'يلزم إعادة تشغيل التطبيق لتطبيقها  في بعض الأماكن'""",
    ),
    const Empty(
      isImage: false,
      icon: Icons.shuffle,
      title: "السبحة المتغيرة",
      description: """
اضافة خاصية جديدة للسبحة وهي الأذكار المتغيرة
بتفعيلها يقوم التطبيق بتديل عشوائي للأذكار أمامك""",
    ),
    const Empty(
      isImage: false,
      icon: Icons.notifications,
      title: "تعديل التنبيهات من الواجهة مباشرة",
      description: """
يمكنك الآن تعديل المنبهات من الواجهة مباشرة
عن طريق الضغط المطول على أيقونة الإشعارات وهي مفعلة""",
    ),
    const Empty(
      isImage: false,
      icon: Icons.brush,
      title: "شريط تقدم إضافي",
      description: """
اضافة شريط اضافي لتقدمك
عند قراءة الأذكار يقوم بحساب كل تسبيحة""",
    ),
    const Empty(
      isImage: false,
      icon: Icons.brush,
      title: "تعديلات في الواجهة",
      description: """
- بعض التعديلات في القائمة الجانبية في الصفحة الرئيسية
- بعض التعديلات في واجهة مشاركة الذكر كصورة
- يمكنك الآن حذف التشكيل عند مشاركة الذكر كصورة
""",
    ),
    const Empty(
      isImage: false,
      icon: MdiIcons.camera,
      title: "مشاركة كصورة",
      description: """
مشاركة الأحاديث المنتشرة التي لا تصح كصورة
""",
    ),
    const Empty(
      isImage: false,
      icon: MdiIcons.bugOutline,
      title: "المشاكل التي تم حلها",
      description: """
- إصلاح الخلل الذي يسبب توقف التطبيق على هواتف من اصدار أندرويد 13
- إصلاح الخلل الخاص بارسال الأخطاء الإملائية
- اصلاح الخلل الذي يظهر عند اضافة عداد جديد في السبحة
""",
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
    appData.changIsFirstOpenToThisRelease(false);
    transitionAnimation.circleRevalPushReplacement(
      context: Get.context!,
      goToPage: const AzkarDashboard(),
    );
  }
}
