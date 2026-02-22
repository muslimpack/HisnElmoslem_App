import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/empty.dart';
import 'package:hisnelmoslem/src/core/utils/volume_button_manager.dart';
import 'package:hisnelmoslem/src/features/settings/data/repository/app_settings_repo.dart';
import 'package:package_info_plus/package_info_plus.dart';

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

    pageController.addListener(() {
      final int index = pageController.page!.round();
      onPageChanged(index);
    });
  }

  ///TODO: Change every release
  List<Empty> get pageData {
    return [
      const Empty(
        title: "الجديد في هذا الإصدار",
        isImage: false,
        isItemList: true,
        description: """
النسخ الاحتياطي والاستعادة محليا
الأذكار الصوتية لمشهور الأذكار
تحسينات على السبحة
يمكنك تخصيص الاهتزازات عند التسبيح من إدارة المؤثرات
مشاركة الذكر كصورة: إضافة الصورة مباشرة إلى معرض الصور
تحسينات على الإشعارات ودعمها لمنصة الويندوز
""",
      ),
    ];
  }

  Future start() async {
    emit(
      OnboardLoadedState(
        showSkipBtn: true,
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
    await appSettingsRepo.changCurrentVersion(value: sl<PackageInfo>().version);
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
