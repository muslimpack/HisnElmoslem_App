import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/empty.dart';
import 'package:hisnelmoslem/src/core/utils/volume_button_manager.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/settings/data/repository/app_settings_repo.dart';

part 'onboard_state.dart';

class OnboardCubit extends Cubit<OnboardState> {
  final AppSettingsRepo appSettingsRepo;
  final VolumeButtonManager volumeButtonManager;
  PageController pageController = PageController();
  OnboardCubit(this.appSettingsRepo, this.volumeButtonManager)
      : super(OnboardLoadingState()) {
    _init();
  }

  void _init() {
    volumeButtonManager.toggleActivation(activate: true);
    volumeButtonManager.listen(
      onVolumeDownPressed: () {
        pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
        );
      },
      onVolumeUpPressed: () {
        pageController.previousPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
        );
      },
    );

    pageController.addListener(
      () {
        final int index = pageController.page!.round();
        onPageChanged(index);
      },
    );
  }

  ///TODO: Change every release
  List<Empty> get pageData {
    return [
//       const Empty(
//         title: "حصن المسلم الإصدار $kAppVersion",
//         description: '''
// السلام عليكم أيها الكريم
// أهلا بك في تحديث جديد من حصن المسلم
// قم بسحب الشاشة لتقليب الصفحات
// أو استخدم مفاتيح الصوت لرؤية الميزات الجديدة
// ''',
//       ),
      const Empty(
        title: "إصدار ثانوي محسن",
        isImage: false,
        icon: Icons.new_releases,
        description: """
- ⚙️ التحكم في نافذة استعادة جلسة الذكر: من الإعدادات.
- 🔕 إمكانية حذف التنبيهات: مباشرة من المحرر عبر الضغط المطوّل على أيقونة الجرس.
- 🧮 حذف عدادات السبحة: يمكنك الآن حذفها مباشرة من المحرر.
- 📝 تحسين نظام تصفية الأذكار: المأخوذة من "موطأ مالك".
- 🌅 حل مشكلة اختفاء الذكر الأخير: في أذكار الصباح والمساء عند تفعيل تصفية مصادر الأذكار.
- 🛠️ إصلاح مشكلة تعطل التطبيق: عند عدم منح الأذونات الخاصة بالإشعارات.
""",
      ),
      /*     const Empty(
        title: "الميزات الجديدة",
        isImage: false,
        icon: Icons.new_releases,
      ),
      const Empty(
        title: "التحسينات",
        isImage: false,
        icon: Icons.more_horiz,
      ),
      const Empty(
        title: "الأعطال التي تم حلها",
        isImage: false,
        icon: Icons.bug_report_outlined,
      ),
      Empty(
        title: "المزيد من تطبيقاتنا",
        isImage: false,
        icon: MdiIcons.web,
        description: """
يمكنك دائما الإطلاع على المزيد من تطبيقاتنا
ومشاركة الرابط مع أصدقائك 
تم إضافة زر جديد للقائمة الجانبية في الواجهة
""",
        buttonText: S.current.moreApps,
        onButtonCLick: () {
          openURL(kOrgWebsite);
        },
      ), */
    ];
  }

  Future start() async {
    emit(
      OnboardLoadedState(
        showSkipBtn: false,
        currentPageIndex: 0,
        pages: pageData,
      ),
    );
  }

  Future onPageChanged(int index) async {
    final state = this.state;
    if (state is! OnboardLoadedState) return;
    emit(state.copyWith(currentPageIndex: index));
  }

  Future done() async {
    await appSettingsRepo.changCurrentVersion(value: kAppVersion);
    volumeButtonManager.dispose();
    emit(OnboardDoneState());
  }

  @override
  Future<void> close() {
    pageController.dispose();
    volumeButtonManager.dispose();
    return super.close();
  }
}
