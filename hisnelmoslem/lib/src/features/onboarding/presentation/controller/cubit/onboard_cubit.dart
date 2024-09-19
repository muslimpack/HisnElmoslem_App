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
        title: "الميزات الجديدة",
        isImage: false,
        icon: Icons.new_releases,
        description: """
- 🖥️ دعم منصات الويندز  
- 🔄 إمكانية استكمال جلسة الذكر السابقة  
- 🔍 تصفية الأذكار من خلال المصدر والحكم  
- 📅 تصفية الأبواب من خلال معدل التكرار (يومي - أسبوعي - شهري - سنوي)  
- 🌙 إمكانية التغيير للوضع الليلي مباشرة من الأذكار  
- 🔁 زر لإعادة تعيين الأذكار في وضع الصفحات والبطاقات  
- 🔊 التحكم في التسبيح من خلال أزرار الصوت عبر الإعدادات  
- 🔤 إضافة خط جديد "Roboto" يمكنك تحديد خط من خلال الإعدادات
""",
      ),
      const Empty(
        title: "التحسينات",
        isImage: false,
        icon: Icons.more_horiz,
        description: """
- 📿 تحسين على السبحة  
- ➡️ إمكانية الانتقال للذكر التالي حتى بعد انتهاء الذكر  
- 🔍 صفحة البحث عن الأبواب  
- 💳 تحسين بطاقات وشكل السبحة  
- ❤️ بطاقات الذكر المفضل على الواجهة  
- ✨ تفعيل المؤثرات لبطاقات الذكر المفضل على الواجهة  
- 📱 تحسين النوافذ المنبثقة  
- ✍️ تحسين عناصر الإدخال  
- 🔒 تعطيل رؤية التطبيق بعد قفل الشاشة
""",
      ),
      const Empty(
        title: "الأعطال التي تم حلها",
        isImage: false,
        icon: Icons.bug_report_outlined,
        description: """
- 🔔 إصلاح مشكلة عداد الإشعارات  
- ⏰ إصلاح مشكلة الانتقال لذكر آخر عند الضغط على منبه لذكر معين  
- 📝 تصويب بعض الأخطاء الإملائية
""",
      ),
      const Empty(
        title: "أخري",
        isImage: false,
        icon: Icons.more_horiz_rounded,
        description: """
- حذف تاريخ التحديثات
""",
      ),
    ];
  }

  Future start() async {
    if (!appSettingsRepo.isReleaseFirstOpen) {
      emit(OnboardDoneState());
      return;
    }
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
    await appSettingsRepo.changIsReleaseFirstOpen(value: false);
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
