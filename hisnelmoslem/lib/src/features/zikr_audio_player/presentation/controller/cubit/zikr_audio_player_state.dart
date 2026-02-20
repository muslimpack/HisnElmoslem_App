part of 'zikr_audio_player_cubit.dart';

class ZikrAudioPlayerState extends Equatable {
  final bool isPlaying;
  final bool isPaused;
  final bool autoPlay;
  final int currentIndex;
  final double playbackSpeed;
  final double volume;
  final AudioDelayTypeEnum delayType;
  final int delayDuration;
  final AudioRepeatTypeEnum repeatType;
  final Duration position;
  final Duration totalDuration;
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
    this.volume = 1.0,
    this.delayType = AudioDelayTypeEnum.none,
    this.delayDuration = 5,
    this.repeatType = AudioRepeatTypeEnum.byZikrCount,
    this.position = Duration.zero,
    this.totalDuration = Duration.zero,
    this.zikrList = const [],
  });

  ZikrAudioPlayerState copyWith({
    bool? isPlaying,
    bool? isPaused,
    bool? autoPlay,
    int? currentIndex,
    double? playbackSpeed,
    double? volume,
    AudioDelayTypeEnum? delayType,
    int? delayDuration,
    AudioRepeatTypeEnum? repeatType,
    Duration? position,
    Duration? totalDuration,
    List<DbContent>? zikrList,
  }) {
    return ZikrAudioPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      isPaused: isPaused ?? this.isPaused,
      autoPlay: autoPlay ?? this.autoPlay,
      currentIndex: currentIndex ?? this.currentIndex,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      volume: volume ?? this.volume,
      delayType: delayType ?? this.delayType,
      delayDuration: delayDuration ?? this.delayDuration,
      repeatType: repeatType ?? this.repeatType,
      position: position ?? this.position,
      totalDuration: totalDuration ?? this.totalDuration,
      zikrList: zikrList ?? this.zikrList,
    );
  }

  @override
  List<Object?> get props => [
    isPlaying,
    isPaused,
    currentIndex,
    playbackSpeed,
    volume,
    delayType,
    delayDuration,
    repeatType,
    position,
    totalDuration,
    zikrList,
  ];
}
