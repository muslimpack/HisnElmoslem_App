part of 'zikr_recorder_cubit.dart';

enum ZikrRecorderStatus {
  /// Nothing recorded yet (or the take was discarded).
  idle,
  recording,

  /// A take is ready to be previewed, saved or re-recorded.
  recorded,

  /// The microphone permission was refused.
  permissionDenied,

  /// The recorder could not start or stopped with an error.
  failed,
}

class ZikrRecorderState extends Equatable {
  final ZikrRecorderStatus status;

  /// Length of the current or finished take.
  final Duration elapsed;

  /// Input level 0..1 while recording, used for the pulse animation.
  final double level;

  /// Name (see `CustomAudioStorage`) of the finished take.
  final String? takeFileName;

  const ZikrRecorderState({
    this.status = ZikrRecorderStatus.idle,
    this.elapsed = Duration.zero,
    this.level = 0,
    this.takeFileName,
  });

  bool get isRecording => status == ZikrRecorderStatus.recording;
  bool get hasTake => status == ZikrRecorderStatus.recorded && takeFileName != null;

  ZikrRecorderState copyWith({
    ZikrRecorderStatus? status,
    Duration? elapsed,
    double? level,
    String? takeFileName,
    bool clearTake = false,
  }) {
    return ZikrRecorderState(
      status: status ?? this.status,
      elapsed: elapsed ?? this.elapsed,
      level: level ?? this.level,
      takeFileName: clearTake ? null : (takeFileName ?? this.takeFileName),
    );
  }

  @override
  List<Object?> get props => [status, elapsed, level, takeFileName];
}
