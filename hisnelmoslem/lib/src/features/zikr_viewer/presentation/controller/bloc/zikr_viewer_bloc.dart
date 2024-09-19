import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/functions/show_toast.dart';
import 'package:hisnelmoslem/src/core/utils/email_manager.dart';
import 'package:hisnelmoslem/src/core/utils/volume_button_manager.dart';
import 'package:hisnelmoslem/src/features/effects_manager/presentation/controller/effects_manager.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/home/data/repository/hisn_db_helper.dart';
import 'package:hisnelmoslem/src/features/home/presentation/controller/bloc/home_bloc.dart';
import 'package:hisnelmoslem/src/features/settings/data/repository/app_settings_repo.dart';
import 'package:hisnelmoslem/src/features/zikr_source_filter/data/models/zikr_filter.dart';
import 'package:hisnelmoslem/src/features/zikr_source_filter/data/models/zikr_filter_list_extension.dart';
import 'package:hisnelmoslem/src/features/zikr_source_filter/data/repository/zikr_filter_repo.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content_extension.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_viewer_mode.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/repository/zikr_viewer_repo.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

part 'zikr_viewer_event.dart';
part 'zikr_viewer_state.dart';

class ZikrViewerBloc extends Bloc<ZikrViewerEvent, ZikrViewerState> {
  PageController pageController = PageController();
  final EffectsManager effectsManager;
  final VolumeButtonManager volumeButtonManager;
  final HomeBloc homeBloc;
  final HisnDBHelper hisnDBHelper;
  final ZikrViewerRepo zikrViewerRepo;
  final ZikrFilterRepo zikrFilterRepo;
  ZikrViewerBloc(
    this.effectsManager,
    this.homeBloc,
    this.hisnDBHelper,
    this.volumeButtonManager,
    this.zikrViewerRepo,
    this.zikrFilterRepo,
  ) : super(ZikrViewerLoadingState()) {
    _initHandlers();
  }

  void _initZikrPageMode(ZikrViewerMode zikrViewerMode) {
    if (zikrViewerMode != ZikrViewerMode.page) return;

    volumeButtonManager.toggleActivation(
      activate: sl<AppSettingsRepo>().praiseWithVolumeKeys,
    );

    volumeButtonManager.listen(
      onVolumeUpPressed: () => add(const ZikrViewerDecreaseZikrEvent()),
      onVolumeDownPressed: () => add(const ZikrViewerDecreaseZikrEvent()),
    );

    pageController.addListener(() {
      final int index = pageController.page!.round();
      add(ZikrViewerPageChangeEvent(index));
    });
  }

  void _initHandlers() {
    on<ZikrViewerPageChangeEvent>(_pageChange);

    on<ZikrViewerStartEvent>(_start);
    on<ZikrViewerRestoreSessionEvent>(_restoreSession);
    on<ZikrViewerSaveSessionEvent>(_saveSession);
    on<ZikrViewerResetSessionEvent>(_resetSession);

    on<ZikrViewerDecreaseZikrEvent>(_decreaaseActiveZikr);
    on<ZikrViewerResetZikrEvent>(_resetActiveZikr);

    on<ZikrViewerCopyZikrEvent>(_copyActiveZikr);
    on<ZikrViewerShareZikrEvent>(_shareActiveZikr);
    on<ZikrViewerToggleZikrBookmarkEvent>(_toggleBookmark);
    on<ZikrViewerReportZikrEvent>(_report);
  }

  FutureOr<void> _start(
    ZikrViewerStartEvent event,
    Emitter<ZikrViewerState> emit,
  ) async {
    if (sl<AppSettingsRepo>().enableWakeLock) {
      WakelockPlus.enable();
    }

    final title = await hisnDBHelper.getTitleById(id: event.titleIndex);

    final azkarFromDB = await hisnDBHelper.getContentsByTitleId(
      titleId: event.titleIndex,
    );

    final List<Filter> filters = zikrFilterRepo.getAllFilters();
    final filteredAzkar = filters.getFilteredZikr(azkarFromDB);

    final azkarToView = List<DbContent>.from(filteredAzkar);

    _initZikrPageMode(event.zikrViewerMode);

    final restoredSession =
        await zikrViewerRepo.getLastSession(event.titleIndex);
    emit(
      ZikrViewerLoadedState(
        title: title,
        azkar: filteredAzkar,
        azkarToView: azkarToView,
        zikrViewerMode: event.zikrViewerMode,
        activeZikrIndex: 0,
        restoredSession: restoredSession ?? {},
      ),
    );
  }

  FutureOr<void> _restoreSession(
    ZikrViewerRestoreSessionEvent event,
    Emitter<ZikrViewerState> emit,
  ) async {
    final state = this.state;
    if (state is! ZikrViewerLoadedState) return;

    if (!event.restore) {
      emit(state.copyWith(restoredSession: {}));
      return;
    }

    final restoredSession = state.restoredSession;
    if (restoredSession.isEmpty) return;

    final azkarToView = List<DbContent>.from(state.azkarToView)
        .map((x) => x.copyWith(count: restoredSession[x.id] ?? x.count))
        .toList();

    int pageToJump = 0;
    for (var i = 0; i < azkarToView.length; i++) {
      if (azkarToView[i].count != 0) {
        pageToJump = i;
        break;
      }
    }

    if (pageController.hasClients) {
      pageController.jumpToPage(pageToJump);
    }

    emit(state.copyWith(azkarToView: azkarToView, restoredSession: {}));
  }

  FutureOr<void> _saveSession(
    ZikrViewerSaveSessionEvent event,
    Emitter<ZikrViewerState> emit,
  ) async {
    final state = this.state;
    if (state is! ZikrViewerLoadedState) return;

    await zikrViewerRepo.saveSession(
      state.title.id,
      {for (final zikr in state.azkarToView) zikr.id: zikr.count},
    );
  }

  FutureOr<void> _resetSession(
    ZikrViewerResetSessionEvent event,
    Emitter<ZikrViewerState> emit,
  ) async {
    final state = this.state;
    if (state is! ZikrViewerLoadedState) return;

    await zikrViewerRepo.resetSession(state.title.id);
  }

  FutureOr<void> _pageChange(
    ZikrViewerPageChangeEvent event,
    Emitter<ZikrViewerState> emit,
  ) async {
    final state = this.state;
    if (state is! ZikrViewerLoadedState) return;

    emit(
      state.copyWith(
        activeZikrIndex: event.index,
      ),
    );
  }

  FutureOr<void> _decreaaseActiveZikr(
    ZikrViewerDecreaseZikrEvent event,
    Emitter<ZikrViewerState> emit,
  ) async {
    final state = this.state;
    if (state is! ZikrViewerLoadedState) return;
    final activeZikr =
        _getZikrToDealWith(state: state, eventContent: event.content);
    if (activeZikr == null) return;
    final activeZikrIndex =
        state.azkarToView.indexWhere((x) => x.id == activeZikr.id);

    final int count = activeZikr.count;

    final azkarToView = List<DbContent>.from(state.azkarToView);

    if (count > 0) {
      azkarToView[activeZikrIndex] = activeZikr.copyWith(count: count - 1);

      effectsManager.playPraiseEffects();
      add(const ZikrViewerSaveSessionEvent());
    }

    if (count == 1) {
      effectsManager.playZikrEffects();
      final totalProgress =
          azkarToView.where((x) => x.count == 0).length / azkarToView.length;

      if (totalProgress == 1) {
        effectsManager.playTitleEffects();
        add(const ZikrViewerResetSessionEvent());
      }
    }

    if (count <= 1) {
      if (pageController.hasClients) {
        pageController.nextPage(
          curve: Curves.easeIn,
          duration: const Duration(milliseconds: 350),
        );
      }
    }

    emit(state.copyWith(azkarToView: azkarToView));
  }

  FutureOr<void> _resetActiveZikr(
    ZikrViewerResetZikrEvent event,
    Emitter<ZikrViewerState> emit,
  ) async {
    final state = this.state;
    if (state is! ZikrViewerLoadedState) return;
    final activeZikr =
        _getZikrToDealWith(state: state, eventContent: event.content);
    if (activeZikr == null) return;

    final originalZikr =
        state.azkar.where((x) => x.id == activeZikr.id).firstOrNull;
    if (originalZikr == null) return;

    final azkarToView = List<DbContent>.from(state.azkarToView).map((x) {
      if (x.id == originalZikr.id) {
        return originalZikr;
      }
      return x;
    }).toList();

    emit(state.copyWith(azkarToView: azkarToView));
  }

  FutureOr<void> _copyActiveZikr(
    ZikrViewerCopyZikrEvent event,
    Emitter<ZikrViewerState> emit,
  ) async {
    final state = this.state;
    if (state is! ZikrViewerLoadedState) return;
    final activeZikr =
        _getZikrToDealWith(state: state, eventContent: event.content);
    if (activeZikr == null) return;

    final text = await activeZikr.getPlainText();
    await Clipboard.setData(
      ClipboardData(text: "$text\n${activeZikr.fadl}"),
    );

    showToast(
      msg: S.current.copiedToClipboard,
    );
  }

  FutureOr<void> _shareActiveZikr(
    ZikrViewerShareZikrEvent event,
    Emitter<ZikrViewerState> emit,
  ) async {
    final state = this.state;
    if (state is! ZikrViewerLoadedState) return;
    final activeZikr =
        _getZikrToDealWith(state: state, eventContent: event.content);
    if (activeZikr == null) return;

    final text = await activeZikr.getPlainText();

    await Share.share("$text\n${activeZikr.fadl}");
  }

  FutureOr<void> _toggleBookmark(
    ZikrViewerToggleZikrBookmarkEvent event,
    Emitter<ZikrViewerState> emit,
  ) async {
    final state = this.state;
    if (state is! ZikrViewerLoadedState) return;
    final activeZikr =
        _getZikrToDealWith(state: state, eventContent: event.content);
    if (activeZikr == null) return;

    if (event.bookmark) {
      await hisnDBHelper.addContentToFavourite(
        dbContent: activeZikr,
      );
    } else {
      await hisnDBHelper.removeContentFromFavourite(
        dbContent: activeZikr,
      );
    }

    final azkar = List<DbContent>.of(state.azkar).map((e) {
      if (e.id == activeZikr.id) {
        return activeZikr.copyWith(favourite: event.bookmark);
      }
      return e;
    }).toList();

    final azkarToView = List<DbContent>.of(state.azkarToView).map((e) {
      if (e.id == activeZikr.id) {
        return activeZikr.copyWith(favourite: event.bookmark);
      }
      return e;
    }).toList();

    emit(
      state.copyWith(
        azkar: azkar,
        azkarToView: azkarToView,
      ),
    );

    homeBloc.add(HomeUpdateBookmarkedContentsEvent());
  }

  FutureOr<void> _report(
    ZikrViewerReportZikrEvent event,
    Emitter<ZikrViewerState> emit,
  ) async {
    final state = this.state;
    if (state is! ZikrViewerLoadedState) return;
    final activeZikr =
        _getZikrToDealWith(state: state, eventContent: event.content);
    if (activeZikr == null) return;

    final text = await activeZikr.getPlainText();
    EmailManager.sendMisspelledInZikrWithText(
      subject: state.title.name,
      cardNumber: (activeZikr.id + 1).toString(),
      text: text,
    );
  }

  DbContent? _getZikrToDealWith({
    required ZikrViewerLoadedState state,
    DbContent? eventContent,
  }) {
    return state.zikrViewerMode == ZikrViewerMode.page
        ? state.activeZikr
        : eventContent;
  }

  @override
  Future<void> close() {
    WakelockPlus.disable();
    pageController.dispose();
    volumeButtonManager.dispose();
    return super.close();
  }
}
