import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hisnelmoslem/src/core/repos/app_data.dart';
import 'package:hisnelmoslem/src/features/effects_manager/presentation/controller/sounds_manager_controller.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/home/data/repository/azkar_database_helper.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content_extension.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

part 'zikr_page_viewer_event.dart';
part 'zikr_page_viewer_state.dart';

class ZikrPageViewerBloc
    extends Bloc<ZikrPageViewerEvent, ZikrPageViewerState> {
  PageController pageController = PageController();
  final SoundsManagerController soundsManagerController;
  final _volumeBtnChannel = const MethodChannel("volume_button_channel");
  ZikrPageViewerBloc(this.soundsManagerController)
      : super(ZikrPageViewerLoadingState()) {
    _initHandlers();

    _volumeBtnChannel.setMethodCallHandler((call) async {
      if (call.method == "volumeBtnPressed") {
        if (call.arguments == "VOLUME_DOWN_UP") {
          add(ZikrPageViewerDecreaseActiveZikrEvent());
        } else if (call.arguments == "VOLUME_UP_UP") {
          add(ZikrPageViewerDecreaseActiveZikrEvent());
        }
      }
    });

    pageController.addListener(() {
      final int index = pageController.page!.round();
      add(ZikrPageViewerPageChangeEvent(index));
    });
  }

  void _initHandlers() {
    on<ZikrPageViewerStartEvent>(_start);
    on<ZikrPageViewerPageChangeEvent>(_pageChange);

    on<ZikrPageViewerDecreaseActiveZikrEvent>(_decreaaseActiveZikr);
    on<ZikrPageViewerResetActiveZikrEvent>(_resetActiveZikr);

    on<ZikrPageViewerCopyActiveZikrEvent>(_copyActiveZikr);
    on<ZikrPageViewerShareActiveZikrEvent>(_shareActiveZikr);
    on<ZikrPageViewerBookmarkActiveZikrEvent>(_bookmark);
    on<ZikrPageViewerUnbookmarkActiveZikrEvent>(_unbookmark);
  }

  FutureOr<void> _start(
    ZikrPageViewerStartEvent event,
    Emitter<ZikrPageViewerState> emit,
  ) async {
    if (AppData.instance.enableWakeLock) {
      WakelockPlus.enable();
    }

    final title = await azkarDatabaseHelper.getTitleById(id: event.titleIndex);

    final azkar = await azkarDatabaseHelper.getContentsByTitleId(
      titleId: event.titleIndex,
    );
    final azkarToView = List<DbContent>.from(azkar);

    emit(
      ZikrPageViewerLoadedState(
        title: title,
        azkar: azkar,
        azkarToView: azkarToView,
        activeZikrIndex: 0,
      ),
    );
  }

  FutureOr<void> _pageChange(
    ZikrPageViewerPageChangeEvent event,
    Emitter<ZikrPageViewerState> emit,
  ) async {
    final state = this.state;
    if (state is! ZikrPageViewerLoadedState) return;

    emit(
      state.copyWith(
        activeZikrIndex: event.index,
      ),
    );
  }

  FutureOr<void> _decreaaseActiveZikr(
    ZikrPageViewerDecreaseActiveZikrEvent event,
    Emitter<ZikrPageViewerState> emit,
  ) async {
    final state = this.state;
    if (state is! ZikrPageViewerLoadedState) return;
    if (state.activeZikr == null) return;

    final zikr = state.azkarToView[state.activeZikrIndex];
    final int count = zikr.count;

    final azkarToView = List<DbContent>.from(state.azkarToView);

    if (count > 0) {
      azkarToView[state.activeZikrIndex] = zikr.copyWith(count: count - 1);

      SoundsManagerController().playTallyEffects();
      if (count == 0) {
        SoundsManagerController().playZikrDoneEffects();
        SoundsManagerController().playTransitionEffects();
      }
    }

    if (count == 0) {
      pageController.nextPage(
        curve: Curves.easeIn,
        duration: const Duration(milliseconds: 350),
      );
    }

    emit(state.copyWith(azkarToView: azkarToView));
  }

  FutureOr<void> _resetActiveZikr(
    ZikrPageViewerResetActiveZikrEvent event,
    Emitter<ZikrPageViewerState> emit,
  ) async {
    final state = this.state;
    if (state is! ZikrPageViewerLoadedState) return;
    final activeZikr = state.activeZikr;
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
    ZikrPageViewerCopyActiveZikrEvent event,
    Emitter<ZikrPageViewerState> emit,
  ) async {
    final state = this.state;
    if (state is! ZikrPageViewerLoadedState) return;
    final activeZikr = state.activeZikr;
    if (activeZikr == null) return;

    final text = activeZikr.getPlainText();
    await Clipboard.setData(
      ClipboardData(text: "$text\n${activeZikr.fadl}"),
    );
  }

  FutureOr<void> _shareActiveZikr(
    ZikrPageViewerShareActiveZikrEvent event,
    Emitter<ZikrPageViewerState> emit,
  ) async {
    final state = this.state;
    if (state is! ZikrPageViewerLoadedState) return;
    final activeZikr = state.activeZikr;
    if (activeZikr == null) return;

    final text = await activeZikr.getPlainText();

    await Share.share("$text\n${activeZikr.fadl}");
  }

  FutureOr<void> _bookmark(
    ZikrPageViewerBookmarkActiveZikrEvent event,
    Emitter<ZikrPageViewerState> emit,
  ) async {}

  FutureOr<void> _unbookmark(
    ZikrPageViewerUnbookmarkActiveZikrEvent event,
    Emitter<ZikrPageViewerState> emit,
  ) async {}

  @override
  Future<void> close() {
    WakelockPlus.disable();
    pageController.dispose();
    _volumeBtnChannel.setMethodCallHandler(null);
    return super.close();
  }
}
