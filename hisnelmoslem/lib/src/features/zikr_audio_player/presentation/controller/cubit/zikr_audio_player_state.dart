part of 'zikr_audio_player_cubit.dart';

class ZikrAudioPlayerState extends Equatable {
  final bool isPlaying;
  final bool isPaused;
  final bool autoPlay;
  final int currentIndex;
  final double playbackSpeed;
  final List<DbContent> zikrList;
  DbContent? get currentZikr =>
      zikrList.isEmpty || currentIndex < 0 || currentIndex >= zikrList.length
      ? null
      : zikrList[currentIndex];

  const ZikrAudioPlayerState({
    this.isPlaying = false,
    this.autoPlay = true,
    this.isPaused = true,
    this.currentIndex = 0,
    this.playbackSpeed = 1.0,
    this.zikrList = const [],
  });

  ZikrAudioPlayerState copyWith({
    bool? isPlaying,
    bool? isPaused,
    bool? autoPlay,
    int? currentIndex,
    double? playbackSpeed,
    List<DbContent>? zikrList,
  }) {
    return ZikrAudioPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      isPaused: isPaused ?? this.isPaused,
      autoPlay: autoPlay ?? this.autoPlay,
      currentIndex: currentIndex ?? this.currentIndex,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      zikrList: zikrList ?? this.zikrList,
    );
  }

  @override
  List<Object?> get props => [isPlaying, isPaused, currentIndex, playbackSpeed, zikrList];
}
