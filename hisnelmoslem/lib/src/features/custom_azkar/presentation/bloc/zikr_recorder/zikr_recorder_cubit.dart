import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/data/services/audio_recorder_service.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/data/services/custom_audio_storage.dart';

part 'zikr_recorder_state.dart';

/// Records one take for a zikr. The take lives in the recordings folder from the
/// moment it is stopped; the owner decides whether to keep it (save) or [discard] it.
class ZikrRecorderCubit extends Cubit<ZikrRecorderState> {
  final AudioRecorderService recorder;
  final CustomAudioStorage storage;

  /// Recording stops by itself at this length, which keeps files small.
  final Duration maxDuration;

  static const Duration _tick = Duration(milliseconds: 200);

  ZikrRecorderCubit({
    required this.recorder,
    required this.storage,
    this.maxDuration = const Duration(minutes: 3),
  }) : super(const ZikrRecorderState());

  Timer? _timer;
  StreamSubscription<double>? _levelSub;
  String? _recordingFile;

  Future<void> start() async {
    if (state.isRecording) return;

    try {
      if (!await recorder.ensurePermission()) {
        emit(const ZikrRecorderState(status: ZikrRecorderStatus.permissionDenied));
        return;
      }
      // Starting again replaces the previous take.
      await _deleteTake();

      final fileName = storage.newFileName();
      await recorder.start(await storage.pathFor(fileName));
      _recordingFile = fileName;
      emit(const ZikrRecorderState(status: ZikrRecorderStatus.recording));

      _levelSub = recorder.levels().listen((level) {
        if (!isClosed && state.isRecording) emit(state.copyWith(level: level));
      });
      _timer = Timer.periodic(_tick, (_) {
        final elapsed = state.elapsed + _tick;
        if (elapsed >= maxDuration) {
          emit(state.copyWith(elapsed: maxDuration));
          stop();
        } else {
          emit(state.copyWith(elapsed: elapsed));
        }
      });
    } catch (e) {
      hisnPrint('Recorder start error: $e');
      await _stopTimers();
      emit(const ZikrRecorderState(status: ZikrRecorderStatus.failed));
    }
  }

  Future<void> stop() async {
    if (!state.isRecording) return;
    final elapsed = state.elapsed;
    await _stopTimers();

    try {
      await recorder.stop();
      emit(
        ZikrRecorderState(
          status: ZikrRecorderStatus.recorded,
          elapsed: elapsed,
          takeFileName: _recordingFile,
        ),
      );
    } catch (e) {
      hisnPrint('Recorder stop error: $e');
      await _deleteTake();
      emit(const ZikrRecorderState(status: ZikrRecorderStatus.failed));
    }
  }

  /// Drops the current take (recording or finished) and returns to idle.
  Future<void> discard() async {
    await _stopTimers();
    if (state.isRecording) {
      try {
        await recorder.cancel();
      } catch (e) {
        hisnPrint('Recorder cancel error: $e');
      }
    }
    await _deleteTake();
    emit(const ZikrRecorderState());
  }

  /// Hands the finished take over to the caller, who becomes responsible for the file.
  String? keepTake() {
    final file = state.hasTake ? state.takeFileName : null;
    _recordingFile = null;
    return file;
  }

  Future<void> _deleteTake() async {
    final file = _recordingFile;
    _recordingFile = null;
    if (file != null) await storage.delete(file);
  }

  Future<void> _stopTimers() async {
    _timer?.cancel();
    _timer = null;
    await _levelSub?.cancel();
    _levelSub = null;
  }

  @override
  Future<void> close() async {
    await _stopTimers();
    // An unsaved take must not stay behind.
    if (state.isRecording) {
      try {
        await recorder.cancel();
      } catch (e) {
        hisnPrint('Recorder cancel error: $e');
      }
    }
    await _deleteTake();
    await recorder.dispose();
    return super.close();
  }
}
