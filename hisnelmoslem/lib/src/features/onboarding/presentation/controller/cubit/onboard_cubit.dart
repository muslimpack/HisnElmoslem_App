import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hisnelmoslem/src/core/extensions/localization_extesion.dart';
import 'package:hisnelmoslem/src/core/functions/open_url.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/empty.dart';
import 'package:hisnelmoslem/src/core/utils/volume_button_manager.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/settings/data/repository/app_settings_repo.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

part 'onboard_state.dart';

class OnboardCubit extends Cubit<OnboardState> {
  final AppSettingsRepo appSettingsRepo;
  final VolumeButtonManager volumeButtonManager;
  PageController pageController = PageController();
  OnboardCubit(this.appSettingsRepo, this.volumeButtonManager) : super(OnboardLoadingState()) {
    _init();
  }

  void _init() {
    volumeButtonManager.toggleActivation(activate: true);
    volumeButtonManager.listen(
      onVolumeDownPressed: () {
        pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
      },
      onVolumeUpPressed: () {
        pageController.previousPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
        );
      },
    );

    pageController.addListener(() {
      final int index = pageController.page!.round();
      onPageChanged(index);
    });
  }

  ///TODO: Change every release
  List<Empty> get pageData {
    return [
      const Empty(
        title: "حصن المسلم الإصدار $kAppVersion",
        description: '''
السلام عليكم ورحمة الله وبركاته
أهلاً وسهلاً بك في تحديث جديد من تطبيق حصن المسلم
يمكنك سحب الشاشة لتقليب الصفحات،
أو استخدام مفاتيح الصوت لاستعراض الميزات الجديدة.

جزى الله خيراً كل من قدّم رأيه أو بلّغ عن مشكلة ساعدتنا على التطوير 💚
''',
      ),
      const Empty(
        title: "الجديد في هذا الإصدار",
        isImage: false,
        isItemList: true,
        description: """
بناء على العديد من المراجعات تم إعادة ذكر "أستغفر الله وأتوب إليه" إلى أذكار المساء
تحسينات في واجهة السبحة والأذكار مع حركات أنيميشن جديدة أكثر سلاسة وجمالًا.
تحسين البحث ليصبح أكثر دقة وعمقًا.
تصميم جديد لشاشة الأذكار أكثر تركيزًا ووضوحًا لسهولة القراءة والاستخدام.
تحسين شامل للسبحة: تعديل عدد الأذكار، إضافة ذكر جديد، وتجربة استخدام أكثر انسيابية.
تحسين مشاركة الأذكار كصورة بتصميم أنيق ومظهر محسّن.

استعادة جلسة الأذكار اليومية تلقائيًا في نفس اليوم فقط.
وضع إضاءة ديناميكي يتكيّف تلقائيًا مع إعداد النظام في جهازك.
زر مفضّلة جديد لإدارة الأبواب بسهولة من صفحة الأذكار.

إصلاح الأخطاء وإرسال تقرير تلقائي إلى المطوّر في حال حدوث مشكلة.
""",
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
        buttonText: SX.current.moreApps,
        onButtonCLick: () {
          openURL(kOrgWebsite);
        },
      ),
    ];
  }

  Future start() async {
    emit(OnboardLoadedState(showSkipBtn: false, currentPageIndex: 0, pages: pageData));
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
