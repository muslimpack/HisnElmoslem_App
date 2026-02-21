// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'zikr_viewer_bloc.dart';

sealed class ZikrViewerState extends Equatable {
  const ZikrViewerState();

  @override
  List<Object> get props => [];
}

final class ZikrViewerLoadingState extends ZikrViewerState {}

class ZikrViewerLoadedState extends ZikrViewerState {
  final DbTitle title;
  final List<DbContent> azkar;
  final List<DbContent> azkarToView;
  final int activeZikrIndex;
  final ZikrViewerMode zikrViewerMode;
  final ZikrSession restoredSession;
  final bool askToRestoreSession;
  final bool isAudioDelaying;
  final bool isAudioPlaying;

  DbContent? get activeZikr {
    if (azkarToView.isEmpty) return null;
    if (activeZikrIndex == -1) return null;
    return azkarToView[activeZikrIndex];
  }

  double get majorProgress => azkarToView.where((x) => x.count == 0).length / azkarToView.length;

  double get manorProgress =>
      azkarToView.fold(0, (sum, curr) => sum + curr.count) /
      azkar.fold(0, (sum, curr) => sum + curr.count);

  const ZikrViewerLoadedState({
    required this.title,
    required this.azkar,
    required this.azkarToView,
    required this.zikrViewerMode,
    required this.activeZikrIndex,
    required this.restoredSession,
    required this.askToRestoreSession,
    this.isAudioDelaying = false,
    this.isAudioPlaying = false,
  });

  ZikrViewerLoadedState copyWith({
    DbTitle? title,
    List<DbContent>? azkar,
    List<DbContent>? azkarToView,
    ZikrViewerMode? zikrViewerMode,
    int? activeZikrIndex,
    ZikrSession? restoredSession,
    bool? askToRestoreSession,
    bool? isAudioDelaying,
    bool? isAudioPlaying,
  }) {
    return ZikrViewerLoadedState(
      title: title ?? this.title,
      azkar: azkar ?? this.azkar,
      azkarToView: azkarToView ?? this.azkarToView,
      zikrViewerMode: zikrViewerMode ?? this.zikrViewerMode,
      activeZikrIndex: activeZikrIndex ?? this.activeZikrIndex,
      restoredSession: restoredSession ?? this.restoredSession,
      askToRestoreSession: askToRestoreSession ?? this.askToRestoreSession,
      isAudioDelaying: isAudioDelaying ?? this.isAudioDelaying,
      isAudioPlaying: isAudioPlaying ?? this.isAudioPlaying,
    );
  }

  @override
  List<Object> get props => [
    title,
    azkar,
    azkarToView,
    zikrViewerMode,
    activeZikrIndex,
    restoredSession,
    askToRestoreSession,
    isAudioDelaying,
    isAudioPlaying,
  ];
}
