import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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
  //TODO show skip button
  bool get showSkipBtn => false;
  //
  int currentPageIndex = 0;
  //
  static const _volumeBtnChannel = MethodChannel("volume_button_channel");
  //
  final pageList = [
    const Empty(
      title: "حصن المسلم الإصدار 2.0.0",
      description: '''
أهلا بك أيها الكريم في هذا الإصدار الجديد من حصن المسلم 
قم بتقليب الصفحات
أو استخدم مفاتيح الصوت لرؤية الميزات الجديدة 
''',
    ),
    const Empty(
      isImage: false,
      icon: MdiIcons.bookOpenPageVariant,
      title: "إضافة  سورة السجدة",
      description: """
تم إضافة  صورة السجدة برواية حفص عن عاصم
وبذلك اكتملت أذكار المساء داخل التطبيق
""",
    ),
    const Empty(
      isImage: false,
      icon: MdiIcons.vibrate,
      title: "عودة هزاز الهاتف",
      description: """
اهتزاز الهاتف عند التسبيح والذكر
يمكنك تفعيله من الإعدادات إدارة المؤثرات
- اهتزاز عند كل ذكر
- اهتزاز عند انتهاء الذكر
- اهتزاز عند انتهاء جميع الأذكار
""",
    ),
    const Empty(
      isImage: false,
      icon: MdiIcons.bug,
      title: "إصلاح مشكلة الايميل",
      description: """
اكتشفنا أن البريد الذي كان يتم ارسال التقيمات إليه فيه خطأ
لذلك برجاء إن كنت قد أرسلت شكوى أو ميزة تريدها  أو أي شيء قم باعادة إرساله مرة أخرى لنضعه في الاعتبار
وذلك عن طريق الشكاوى والمقترحات أو راسلنا
أو زر تواصل مع المطور من الشاشة الرئيسية
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
    final box = GetStorage();
    box.write("is_v2.0_first_open", false);
    transitionAnimation.circleRevalPushReplacement(
        context: Get.context!, goToPage: const AzkarDashboard());
  }
}
