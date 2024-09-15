import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/core/repos/app_data.dart';
import 'package:hisnelmoslem/src/core/utils/email_manager.dart';
import 'package:hisnelmoslem/src/features/effects_manager/presentation/controller/sounds_manager_controller.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/home/data/repository/azkar_database_helper.dart';
import 'package:hisnelmoslem/src/features/home/presentation/controller/bloc/home_bloc.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content_extension.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_viewer_mode.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

part 'zikr_viewer_event.dart';
part 'zikr_viewer_state.dart';

class ZikrViewerBloc extends Bloc<ZikrViewerEvent, ZikrViewerState> {
  PageController pageController = PageController();
  final SoundsManagerController soundsManagerController;
  final _volumeBtnChannel = const MethodChannel("volume_button_channel");
  final HomeBloc homeBloc;
  final ZikrViewerMode zikrViewerMode;
  final AzkarDatabaseHelper azkarDatabaseHelper;
  ZikrViewerBloc({
    required this.soundsManagerController,
    required this.homeBloc,
    required this.zikrViewerMode,
    required this.azkarDatabaseHelper,
  }) : super(ZikrViewerLoadingState()) {
    _initHandlers();

    _initZikrPageMode();
  }

  void _initZikrPageMode() {
    if (zikrViewerMode != ZikrViewerMode.page) return;

    _volumeBtnChannel.setMethodCallHandler((call) async {
      if (call.method == "volumeBtnPressed") {
        if (call.arguments == "VOLUME_DOWN_UP") {
          add(const ZikrViewerDecreaseZikrEvent());
        } else if (call.arguments == "VOLUME_UP_UP") {
          add(const ZikrViewerDecreaseZikrEvent());
        }
      }
    });

    pageController.addListener(() {
      final int index = pageController.page!.round();
      add(ZikrViewerPageChangeEvent(index));
    });
  }

  void _initHandlers() {
    on<ZikrViewerStartEvent>(_start);
    on<ZikrViewerPageChangeEvent>(_pageChange);

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
    if (AppData.instance.enableWakeLock) {
      WakelockPlus.enable();
    }

    final title = await azkarDatabaseHelper.getTitleById(id: event.titleIndex);

    final azkar = await azkarDatabaseHelper.getContentsByTitleId(
      titleId: event.titleIndex,
    );
    final azkarToView = List<DbContent>.from(azkar);

    emit(
      ZikrViewerLoadedState(
        title: title,
        azkar: azkar,
        azkarToView: azkarToView,
        activeZikrIndex: 0,
      ),
    );
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

      SoundsManagerController().playTallyEffects();
      if (count == 0) {
        await SoundsManagerController().playZikrDoneEffects();
        await SoundsManagerController().playTransitionEffects();
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

    hisnPrint("activeZikr: $activeZikr");

    if (event.bookmark) {
      await azkarDatabaseHelper.addContentToFavourite(
        dbContent: activeZikr,
      );
    } else {
      await azkarDatabaseHelper.removeContentFromFavourite(
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
    return zikrViewerMode == ZikrViewerMode.page
        ? state.activeZikr
        : eventContent;
  }

  @override
  Future<void> close() {
    WakelockPlus.disable();
    pageController.dispose();
    _volumeBtnChannel.setMethodCallHandler(null);
    return super.close();
  }
}
