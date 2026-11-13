// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/audio_source_choice.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/audio_source_resolver.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/reciter.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/data/models/audio_delay_type_enum.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/data/models/audio_repeat_type_enum.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/data/repository/zikr_audio_player_repo.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

part 'zikr_audio_player_state.dart';

class ZikrAudioPlayerCubit extends Cubit<ZikrAudioPlayerState> {
  final AudioPlayer _player;
  final ZikrAudioPlayerRepo zikrAudioPlayerRepo;

  /// Chooses between bundled, downloaded and streamed recordings. Without it only the user's
  /// recording and the bundled file are played (the tally uses it that way).
  final AudioSourceResolver? resolver;

  /// The reciter to play, read for every zikr so a change applies from the next one.
  final Reciter Function()? reciter;

  /// The reciters of the website say how many times to repeat at the end of a zikr that is
  /// repeated. The app counts the repetitions itself, so for a recording from the website the
  /// last part of a zikr with a count above one is skipped.
  final Duration remoteTailTrim;

  /// [player] is only given by tests.
  ZikrAudioPlayerCubit(
    this.zikrAudioPlayerRepo, {
    AudioPlayer? player,
    this.resolver,
    this.reciter,
    this.remoteTailTrim = const Duration(milliseconds: 1800),
  }) : _player = player ?? AudioPlayer(playerId: "zikr_audio_player"),
       super(const ZikrAudioPlayerState());

  Function(DbContent zikr)? onDonePlaying;
  int Function(int index)? getActiveZikrCount;

  /// Changes whenever playback is started, paused or stopped. A delay that was waiting
  /// when that happened sees a different value afterwards and ends without playing, so
  /// pausing and resuming during a delay can never start the next zikr twice.
  int _playbackToken = 0;

  /// Sources of the zikr being played. More than one when a zikr spans several recordings;
  /// they play one after the other and count as a single playback.
  List<Source> _parts = const [];
  int _partIndex = 0;

  /// The end of the current recording is skipped (see [remoteTailTrim]); [_tailCut] is set once
  /// that was done for this playback, and [_appliedTrim] is how much was skipped.
  bool _trimTail = false;
  bool _tailCut = false;
  Duration _appliedTrim = Duration.zero;

  StreamSubscription<void>? _completionSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;

  Future<void> init({
    Function(DbContent zikr)? onDonePlaying,
    int Function(int index)? getActiveZikrCount,
    List<DbContent>? zikrList,

    /// When false a finished track is only reported through [onDonePlaying]: nothing
    /// is repeated or started next, the caller decides what to play.
    bool autoPlay = true,
  }) async {
    _playbackToken++;
    this.onDonePlaying = onDonePlaying;
    this.getActiveZikrCount = getActiveZikrCount;
    emit(
      state.copyWith(
        currentIndex: 0,
        isPlaying: false,
        autoPlay: autoPlay,
        playbackSpeed: zikrAudioPlayerRepo.getSpeed(),
        volume: zikrAudioPlayerRepo.getVolume(),
        delayType: zikrAudioPlayerRepo.getDelay(),
        delayDuration: zikrAudioPlayerRepo.getDelayDuration(),
        repeatType: zikrAudioPlayerRepo.getRepeat(),
        position: Duration.zero,
        totalDuration: Duration.zero,
        zikrList: zikrList,
      ),
    );

    try {
      await _player.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.speech,
          ),
          iOS: AudioContextIOS(
            options: const {
              AVAudioSessionOptions.mixWithOthers,
            },
          ),
        ),
      );
    } catch (e) {
      hisnPrint('AudioPlayer Error setting context: $e');
    }

    try {
      await _player.stop();
    } catch (e) {
      hisnPrint('AudioPlayer Error stopping in init: $e');
    }

    _completionSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();

    _completionSub = _player.onPlayerComplete.listen((_) async {
      await _onPlaybackCompleted();
    });

    _positionSub = _player.onPositionChanged.listen((p) {
      if (isClosed) return;
      emit(state.copyWith(position: p));
      _cutTailIfDue(p);
    });

    _durationSub = _player.onDurationChanged.listen((d) {
      if (!isClosed) emit(state.copyWith(totalDuration: d));
    });
  }

  Future<void> saveSettings({
    double? speed,
    double? volume,
    AudioDelayTypeEnum? delayType,
    int? delayDuration,
    AudioRepeatTypeEnum? repeatType,
  }) async {
    zikrAudioPlayerRepo.saveSettings(
      speed: speed,
      volume: volume,
      delay: delayType,
      delayDuration: delayDuration,
      repeat: repeatType,
    );

    if (speed != null) {
      await _player.setPlaybackRate(speed);
      emit(state.copyWith(playbackSpeed: speed));
    }
    if (volume != null) {
      await _player.setVolume(volume);
      emit(state.copyWith(volume: volume));
    }
    if (delayType != null) {
      emit(state.copyWith(delayType: delayType));
    }
    if (delayDuration != null) {
      emit(state.copyWith(delayDuration: delayDuration));
    }
    if (repeatType != null) {
      emit(state.copyWith(repeatType: repeatType));
    }
  }

  /// Ends the recording early when it reached the part the reciter uses to say the count.
  Future<void> _cutTailIfDue(Duration position) async {
    if (!_trimTail || _tailCut || _partIndex != _parts.length - 1) return;
    final total = state.totalDuration;
    // Short recordings are left alone: there is nothing to skip.
    if (total <= remoteTailTrim * 3 || position < total - remoteTailTrim) return;

    _tailCut = true;
    _appliedTrim = remoteTailTrim;
    final token = _playbackToken;
    try {
      await _player.stop();
    } catch (e) {
      hisnPrint('AudioPlayer Error cutting the tail: $e');
    }
    if (isClosed || token != _playbackToken) return;
    await _onPlaybackCompleted();
  }

  Future<void> _handleDelayAndWait() async {
    if (state.delayType == AudioDelayTypeEnum.fixedTime) {
      await Future.delayed(Duration(seconds: state.delayDuration));
    } else if (state.delayType == AudioDelayTypeEnum.byPreviousZikr) {
      final played = state.totalDuration - _appliedTrim;
      final int adjustedMilliseconds =
          ((played.isNegative ? Duration.zero : played).inMilliseconds / state.playbackSpeed)
              .round();
      await Future.delayed(Duration(milliseconds: adjustedMilliseconds));
    }
  }

  Future<void> _onPlaybackCompleted() async {
    emit(state.copyWith(position: Duration.zero));

    // The next recording of the same zikr, if any.
    if (_partIndex + 1 < _parts.length) {
      _partIndex++;
      await _playPart(_parts[_partIndex]);
      return;
    }

    final currentZikr = state.currentZikr;
    final int token = _playbackToken;
    if (currentZikr == null) return;

    final int currentCount = getActiveZikrCount?.call(state.currentIndex) ?? currentZikr.count;

    if (currentCount > 1 && state.repeatType == AudioRepeatTypeEnum.byZikrCount) {
      hisnPrint('count: $currentCount');

      // Set delay state TRUE synchronously
      emit(state.copyWith(isDelayingBetweenZikr: true));

      // Notify Bloc to decrease count.
      // It won't turn page because count > 1.
      onDonePlaying?.call(currentZikr);

      await _handleDelayAndWait();

      // Paused, stopped or restarted while waiting: whoever did that already cleared
      // the delay flag, and this flow must not play anything.
      if (isClosed || token != _playbackToken) return;

      emit(state.copyWith(isDelayingBetweenZikr: false));
      playZikrAt(state.currentIndex);
      return;
    }

    if (state.autoPlay) {
      emit(state.copyWith(isDelayingBetweenZikr: true));

      // Decrease count in UI! This will make count 0.
      // The bloc will see `zikrAudioPlayerCubit.state.isDelayingBetweenZikr` is true,
      // preventing the immediate page turn.
      onDonePlaying?.call(currentZikr);

      await _handleDelayAndWait();

      if (isClosed || token != _playbackToken) return;

      emit(state.copyWith(isDelayingBetweenZikr: false));
      // By now, stream emits false. The bloc receives false and turns the page.

      await _playNextZikr();
    } else {
      // If no autoplay, just finish the zikr track.
      emit(state.copyWith(isPlaying: false, isPaused: false));
      onDonePlaying?.call(currentZikr);
    }
  }

  Future<void> playZikrAt(int index) async {
    if (index < 0 || index >= state.zikrList.length) return;

    final zikr = state.zikrList[index];
    _playbackToken++;

    final choice = await _sourcesOf(zikr);
    final parts = choice.sources;
    _tailCut = false;
    _appliedTrim = Duration.zero;
    _trimTail = choice.remote && zikr.count > 1;
    if (parts.isEmpty) {
      // Many azkar have no audio. Narration ends here; leaving it "playing" would keep
      // the audio bar busy and silence the tap sound effects until stopped by hand.
      try {
        await _player.stop();
      } catch (e) {
        hisnPrint('AudioPlayer Error stopping before a zikr without audio: $e');
      }
      emit(
        state.copyWith(
          currentIndex: index,
          isPlaying: false,
          isPaused: false,
          position: Duration.zero,
          totalDuration: Duration.zero,
          isDelayingBetweenZikr: false,
        ),
      );
      return;
    }

    // The list was copied when the viewer opened, so its counts are stale; ask for the
    // live count to skip azkar that are already done (e.g. restored session).
    final liveCount = getActiveZikrCount?.call(index) ?? zikr.count;
    if (liveCount == 0) {
      emit(state.copyWith(currentIndex: index, isPlaying: true, isDelayingBetweenZikr: false));
      _onPlaybackCompleted();
      return;
    }

    hisnPrint(_player.playerId);

    _parts = parts;
    _partIndex = 0;

    try {
      await _player.stop();

      emit(
        state.copyWith(
          currentIndex: index,
          isPlaying: true,
          isPaused: false,
          position: Duration.zero,
          isDelayingBetweenZikr: false,
        ),
      );

      await _playPart(parts.first);
    } catch (e) {
      hisnPrint('AudioPlayer Error playing Zikr: $e');
      emit(state.copyWith(isPlaying: false, isPaused: false));
    }
  }

  Future<void> _playPart(Source source) async {
    final token = _playbackToken;
    // A recording from the internet takes a moment to load: tell the UI so it can show progress.
    final streaming = source is UrlSource;
    if (streaming) emit(state.copyWith(isLoadingAudio: true));
    try {
      await _player.play(source, volume: state.volume);
      await _player.setPlaybackRate(state.playbackSpeed);
    } catch (e) {
      // A recording that cannot be loaded (for example a stream while offline) is treated like
      // a zikr without audio: narration ends instead of hanging.
      hisnPrint('AudioPlayer Error playing $source: $e');
      if (isClosed || token != _playbackToken) return;
      _parts = const [];
      emit(
        state.copyWith(
          isPlaying: false,
          isPaused: false,
          isDelayingBetweenZikr: false,
          isLoadingAudio: false,
        ),
      );
      return;
    } finally {
      if (streaming && !isClosed && state.isLoadingAudio && token == _playbackToken) {
        emit(state.copyWith(isLoadingAudio: false));
      }
    }
  }

  /// The recordings to play for [zikr], in order; empty when it has none.
  /// [remote] is true when they come from the website (downloaded or streamed).
  Future<({List<Source> sources, bool remote})> _sourcesOf(DbContent zikr) async {
    final AudioSourceChoice choice;
    final r = resolver;
    if (r != null) {
      choice = await r.resolve(zikr, reciter?.call() ?? Reciter.defaultReciter);
    } else if (zikr.userAudioPath.isNotEmpty) {
      choice = UserRecording(zikr.userAudioPath);
    } else if (zikr.audio.isNotEmpty) {
      choice = BundledAsset(zikr.audio);
    } else {
      choice = const NoAudio();
    }

    return switch (choice) {
      NoAudio() => (sources: const <Source>[], remote: false),
      UserRecording(:final path) => (sources: <Source>[DeviceFileSource(path)], remote: false),
      BundledAsset(:final fileName) => (
        sources: <Source>[AssetSource('sounds/azkar/$fileName')],
        remote: false,
      ),
      DownloadedFiles(:final paths) => (
        sources: <Source>[for (final p in paths) DeviceFileSource(p)],
        remote: true,
      ),
      StreamUrls(:final urls) => (
        sources: <Source>[for (final u in urls) UrlSource(u)],
        remote: true,
      ),
    };
  }

  /// Replaces the list with the single [zikr] (used by the tally, which plays one
  /// recording at a time). Playback is not started.
  void setTrack(DbContent zikr) {
    emit(
      state.copyWith(
        zikrList: [zikr],
        currentIndex: 0,
        position: Duration.zero,
        totalDuration: Duration.zero,
      ),
    );
  }

  Future<void> _playNextZikr() async {
    final nextIndex = state.currentIndex + 1;
    if (nextIndex < state.zikrList.length) {
      await playZikrAt(nextIndex);
    } else {
      emit(state.copyWith(isPlaying: false));
    }
  }

  Future<void> playAll() async {
    if (state.zikrList.isEmpty) return;
    try {
      await playZikrAt(state.currentIndex);
    } catch (e) {
      hisnPrint('AudioPlayer Error playAll: $e');
    }
  }

  Future<void> pause() async {
    _playbackToken++;
    try {
      await _player.pause();
      emit(
        state.copyWith(
          isPaused: true,
          isPlaying: false,
          isDelayingBetweenZikr: false,
          isLoadingAudio: false,
        ),
      );
    } catch (e) {
      hisnPrint('AudioPlayer Error pause: $e');
    }
  }

  Future<void> resume() async {
    if (state.currentZikr != null && state.position > Duration.zero) {
      try {
        await _player.resume();
        emit(state.copyWith(isPaused: false, isPlaying: true));
      } catch (e) {
        hisnPrint('AudioPlayer Error resume: $e');
      }
    } else {
      await playAll();
    }
  }

  Future<void> stop() async {
    _playbackToken++;
    try {
      await _player.stop();
      emit(
        state.copyWith(
          isPlaying: false,
          isPaused: false,
          position: Duration.zero,
          isDelayingBetweenZikr: false,
          isLoadingAudio: false,
        ),
      );
    } catch (e) {
      hisnPrint('AudioPlayer Error stop: $e');
      emit(
        state.copyWith(
          isPlaying: false,
          isPaused: false,
          isDelayingBetweenZikr: false,
          isLoadingAudio: false,
        ),
      );
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      hisnPrint('AudioPlayer Error seek: $e');
    }
  }

  Future<void> skipToNextZikr() async {
    final nextIndex = min(state.currentIndex + 1, state.zikrList.length - 1);
    await playZikrAt(nextIndex);
  }

  Future<void> startPlayFromIndex(int index) async {
    await playZikrAt(index);
  }

  @override
  Future<void> close() async {
    await _completionSub?.cancel();
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _player.dispose();
    return super.close();
  }
}
