import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hisnelmoslem/app.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/utils/email_manager.dart';
import 'package:hisnelmoslem/src/core/utils/volume_button_manager.dart';
import 'package:hisnelmoslem/src/features/azkar_filters/data/models/zikr_filter.dart';
import 'package:hisnelmoslem/src/features/azkar_filters/data/models/zikr_filter_list_extension.dart';
import 'package:hisnelmoslem/src/features/azkar_filters/data/repository/azakr_filters_repo.dart';
import 'package:hisnelmoslem/src/features/bookmark/presentation/controller/bloc/bookmark_bloc.dart';
import 'package:hisnelmoslem/src/features/effects_manager/presentation/controller/effects_manager.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/home/data/repository/hisn_db_helper.dart';
import 'package:hisnelmoslem/src/features/home/presentation/controller/bloc/home_bloc.dart';
import 'package:hisnelmoslem/src/features/settings/data/repository/app_settings_repo.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/presentation/controller/cubit/zikr_audio_player_cubit.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content_extension.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_session.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_viewer_mode.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/repository/zikr_viewer_repo.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/zikr_share_dialog.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

part 'zikr_viewer_event.dart';
part 'zikr_viewer_state.dart';

class ZikrViewerBloc extends Bloc<ZikrViewerEvent, ZikrViewerState> {
  PageController pageController = PageController();
  final EffectsManager effectsManager;
  final VolumeButtonManager volumeButtonManager;
  final HomeBloc homeBloc;
  final BookmarkBloc bookmarkBloc;
  final HisnDBHelper hisnDBHelper;
  final ZikrViewerRepo zikrViewerRepo;
  final AzkarFiltersRepo azkarFiltersRepo;
  final ZikrAudioPlayerCubit zikrAudioPlayerCubit;
  ZikrViewerBloc(
    this.effectsManager,
    this.homeBloc,
    this.bookmarkBloc,
    this.hisnDBHelper,
    this.volumeButtonManager,
    this.zikrViewerRepo,
    this.azkarFiltersRepo,
    this.zikrAudioPlayerCubit,
  ) : super(ZikrViewerLoadingState()) {
    _initHandlers();
  }

  void _initZikrPageMode(ZikrViewerMode zikrViewerMode) {
    if (zikrViewerMode != ZikrViewerMode.page) return;

    volumeButtonManager.toggleActivation(
      activate: sl<AppSettingsRepo>().praiseWithVolumeKeys,
    );

    volumeButtonManager.listen(
      onVolumeUpPressed: () => add(const ZikrViewerVolumeKeyPressedEvent()),
      onVolumeDownPressed: () => add(const ZikrViewerVolumeKeyPressedEvent()),
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
    on<ZikrViewerReportZikrEvent>(_report);

    on<ZikrViewerVolumeKeyPressedEvent>(_volumeKeyPressed);

    on<ZikrViewerAudioDelayStateChangedEvent>(_audioDelayStateChanged);
    on<ZikrViewerAudioPlayingStateChangedEvent>(_audioPlayingStateChanged);
  }

  Future<void> _start(
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

    final List<Filter> filters = azkarFiltersRepo.getAllFilters;
    final filteredAzkar = filters.getFilteredZikr(azkarFromDB);

    final azkarToView = List<DbContent>.from(filteredAzkar);

    _initZikrPageMode(event.zikrViewerMode);

    final restoredSession = zikrViewerRepo.getLastSession(event.titleIndex);
    final askToRestoreSession =
        zikrViewerRepo.allowZikrSessionRestoration &&
        restoredSession != null &&
        restoredSession.data.isNotEmpty &&
        DateUtils.isSameDay(restoredSession.dateTime, DateTime.now());

    zikrAudioPlayerCubit.init(
      zikrList: azkarToView,
      onDonePlaying: (zikr) {
        add(ZikrViewerDecreaseZikrEvent(content: zikr));
      },
      getActiveZikrCount: (index) {
        if (isClosed) return 0;
        final currentState = state;
        if (currentState is ZikrViewerLoadedState) {
          if (index >= 0 && index < currentState.azkarToView.length) {
            return currentState.azkarToView[index].count;
          }
        }
        return 0;
      },
    );

    StreamSubscription? audioStateSubscription;
    audioStateSubscription = zikrAudioPlayerCubit.stream.listen((audioState) {
      if (isClosed) {
        audioStateSubscription?.cancel();
        return;
      }
      final state = this.state;
      if (state is ZikrViewerLoadedState) {
        if (state.isAudioPlaying != audioState.isPlaying) {
          add(ZikrViewerAudioPlayingStateChangedEvent(audioState.isPlaying));
        }
      }
      add(
        ZikrViewerAudioDelayStateChangedEvent(audioState.isDelayingBetweenZikr),
      );
    });

    emit(
      ZikrViewerLoadedState(
        title: title,
        azkar: filteredAzkar,
        azkarToView: azkarToView,
        zikrViewerMode: event.zikrViewerMode,
        activeZikrIndex: 0,
        restoredSession: restoredSession ?? ZikrSession(dateTime: DateTime.now(), data: const {}),
        askToRestoreSession: askToRestoreSession,
      ),
    );
  }

  Future<void> _restoreSession(
    ZikrViewerRestoreSessionEvent event,
    Emitter<ZikrViewerState> emit,
  ) async {
    final state = this.state;
    if (state is! ZikrViewerLoadedState) return;

    if (!event.restore) {
      emit(state.copyWith(askToRestoreSession: false));
      return;
    }

    final restoredSession = state.restoredSession;
    if (restoredSession.data.isEmpty) return;

    final azkarToView = List<DbContent>.from(
      state.azkarToView,
    ).map((x) => x.copyWith(count: restoredSession.data[x.id] ?? x.count)).toList();

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

    emit(state.copyWith(azkarToView: azkarToView, askToRestoreSession: false));
  }

  Future<void> _saveSession(
    ZikrViewerSaveSessionEvent event,
    Emitter<ZikrViewerState> emit,
  ) async {
    final state = this.state;
    if (state is! ZikrViewerLoadedState) return;

    await zikrViewerRepo.saveSession(
      state.title.id,
      ZikrSession(
        dateTime: DateTime.now(),
        data: {for (final zikr in state.azkarToView) zikr.id: zikr.count},
      ),
    );
  }

  Future<void> _resetSession(
    ZikrViewerResetSessionEvent event,
    Emitter<ZikrViewerState> emit,
  ) async {
    final state = this.state;
    if (state is! ZikrViewerLoadedState) return;

    await zikrViewerRepo.resetSession(state.title.id);
  }

  Future<void> _pageChange(
    ZikrViewerPageChangeEvent event,
    Emitter<ZikrViewerState> emit,
  ) async {
    final state = this.state;
    if (state is! ZikrViewerLoadedState) return;

    // Optional: If the user swipes, the audio player should match the current page if it's playing.
    // If the audio player index doesn't match the new page index, we might need to sync.
    if (zikrAudioPlayerCubit.state.isPlaying &&
        zikrAudioPlayerCubit.state.currentIndex != event.index) {
      zikrAudioPlayerCubit.startPlayFromIndex(event.index);
    }

    emit(state.copyWith(activeZikrIndex: event.index));
  }

  Future<void> _decreaaseActiveZikr(
    ZikrViewerDecreaseZikrEvent event,
    Emitter<ZikrViewerState> emit,
  ) async {
    final state = this.state;
    if (state is! ZikrViewerLoadedState) return;
    final activeZikr = _getZikrToDealWith(
      state: state,
      eventContent: event.content,
    );
    if (activeZikr == null) return;
    final activeZikrIndex = state.azkarToView.indexWhere(
      (x) => x.id == activeZikr.id,
    );

    final int count = activeZikr.count;

    final azkarToView = List<DbContent>.from(state.azkarToView);

    if (count > 0) {
      azkarToView[activeZikrIndex] = activeZikr.copyWith(count: count - 1);

      effectsManager.playPraiseEffects();
      add(const ZikrViewerSaveSessionEvent());
    }

    if (count == 1) {
      effectsManager.playZikrEffects();
      final totalProgress = azkarToView.where((x) => x.count == 0).length / azkarToView.length;

      if (totalProgress == 1) {
        effectsManager.playTitleEffects();
        add(const ZikrViewerResetSessionEvent());
      }
    }

    if (count <= 1) {
      // If we are currently in an audio delay phase, we DO NOT turn the page yet.
      // We wait for the audio delay to finish (`isAudioDelaying` going to false) to turn it.
      // We check both the bloc state and the cubit state directly to avoid stream race conditions.
      final isDelayingBloc = state.isAudioDelaying;
      final isDelayingCubit = zikrAudioPlayerCubit.state.isDelayingBetweenZikr;

      if (!isDelayingBloc && !isDelayingCubit) {
        _turnPage();
      }
    }

    emit(state.copyWith(azkarToView: azkarToView));
  }

  void _turnPage() {
    if (pageController.hasClients) {
      final state = this.state;
      if (state is ZikrViewerLoadedState) {
        if (state.activeZikrIndex < state.azkarToView.length - 1) {
          pageController.nextPage(
            curve: Curves.easeIn,
            duration: const Duration(milliseconds: 350),
          );
        }
      }
    }
  }

  Future<void> _audioDelayStateChanged(
    ZikrViewerAudioDelayStateChangedEvent event,
    Emitter<ZikrViewerState> emit,
  ) async {
    final state = this.state;
    if (state is! ZikrViewerLoadedState) return;

    final wasDelaying = state.isAudioDelaying;
    emit(state.copyWith(isAudioDelaying: event.isDelaying));

    // If the delay just finished (transitioned from true to false),
    // and the current active zikr is completely done (count == 0),
    // we should turn the page now.
    if (wasDelaying && !event.isDelaying) {
      final activeZikr = state.activeZikr;

      if (activeZikr != null && activeZikr.count == 0) {
        _turnPage();
      }
    }
  }

  Future<void> _audioPlayingStateChanged(
    ZikrViewerAudioPlayingStateChangedEvent event,
    Emitter<ZikrViewerState> emit,
  ) async {
    final state = this.state;
    if (state is! ZikrViewerLoadedState) return;

    if (state.zikrViewerMode == ZikrViewerMode.page) {
      if (event.isPlaying) {
        volumeButtonManager.toggleActivation(activate: false);
      } else {
        volumeButtonManager.toggleActivation(
          activate: sl<AppSettingsRepo>().praiseWithVolumeKeys,
        );
      }
    }

    emit(state.copyWith(isAudioPlaying: event.isPlaying));
  }

  Future<void> _resetActiveZikr(
    ZikrViewerResetZikrEvent event,
    Emitter<ZikrViewerState> emit,
  ) async {
    final state = this.state;
    if (state is! ZikrViewerLoadedState) return;
    final activeZikr = _getZikrToDealWith(
      state: state,
      eventContent: event.content,
    );
    if (activeZikr == null) return;

    final originalZikr = state.azkar.where((x) => x.id == activeZikr.id).firstOrNull;
    if (originalZikr == null) return;

    final azkarToView = List<DbContent>.from(state.azkarToView).map((x) {
      if (x.id == originalZikr.id) {
        return originalZikr;
      }
      return x;
    }).toList();

    emit(state.copyWith(azkarToView: azkarToView));
  }

  Future<void> _copyActiveZikr(
    ZikrViewerCopyZikrEvent event,
    Emitter<ZikrViewerState> emit,
  ) async {
    final state = this.state;
    if (state is! ZikrViewerLoadedState) return;
    final activeZikr = _getZikrToDealWith(
      state: state,
      eventContent: event.content,
    );
    if (activeZikr == null) return;

    showDialog(
      context: App.navigatorKey.currentState!.context,
      builder: (context) {
        return ZikrShareDialog(contentId: activeZikr.id);
      },
    );
  }

  Future<void> _shareActiveZikr(
    ZikrViewerShareZikrEvent event,
    Emitter<ZikrViewerState> emit,
  ) async {
    final state = this.state;
    if (state is! ZikrViewerLoadedState) return;
    final activeZikr = _getZikrToDealWith(
      state: state,
      eventContent: event.content,
    );
    if (activeZikr == null) return;

    showDialog(
      context: App.navigatorKey.currentState!.context,
      builder: (context) {
        return ZikrShareDialog(contentId: activeZikr.id);
      },
    );
  }

  Future<void> _report(
    ZikrViewerReportZikrEvent event,
    Emitter<ZikrViewerState> emit,
  ) async {
    final state = this.state;
    if (state is! ZikrViewerLoadedState) return;
    final activeZikr = _getZikrToDealWith(
      state: state,
      eventContent: event.content,
    );
    if (activeZikr == null) return;

    final text = await activeZikr.getPlainText();
    EmailManager.sendMisspelledInZikr(
      title: state.title.name,
      zikrId: (activeZikr.id + 1).toString(),
      zikrBody: text,
    );
  }

  Future<void> _volumeKeyPressed(
    ZikrViewerVolumeKeyPressedEvent event,
    Emitter<ZikrViewerState> emit,
  ) async {
    final state = this.state;
    if (state is! ZikrViewerLoadedState) return;
    final activeZikr = _getZikrToDealWith(state: state);
    if (activeZikr == null) return;

    add(ZikrViewerDecreaseZikrEvent(content: activeZikr));
  }

  DbContent? _getZikrToDealWith({
    required ZikrViewerLoadedState state,
    DbContent? eventContent,
  }) {
    return state.zikrViewerMode == ZikrViewerMode.page ? state.activeZikr : eventContent;
  }

  @override
  Future<void> close() {
    WakelockPlus.disable();
    pageController.dispose();
    volumeButtonManager.dispose();
    zikrAudioPlayerCubit.stop();
    return super.close();
  }
}
