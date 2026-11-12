import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/data/services/custom_audio_storage.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally_session_limit.dart';
import 'package:hisnelmoslem/src/features/tally/data/repository/tally_repo.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/controller/bloc/tally_bloc.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/data/models/audio_delay_type_enum.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/presentation/controller/cubit/zikr_audio_player_cubit.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

enum TallyAudioPhase { idle, playing, paused }

/// Why a session stopped by itself.
enum TallyAudioEnd {
  /// The minutes or the number of counts the user asked for are done.
  limitReached,

  /// The active counter has no recording (or its file is gone).
  noRecording,
}

/// What the counters looked like when a voice session began, and how many counts it made,
/// so the session can be taken back.
class TallyAudioSummary extends Equatable {
  final int counted;
  final List<DbTally> before;
  final DbTally? activeBefore;

  const TallyAudioSummary({
    required this.counted,
    required this.before,
    required this.activeBefore,
  });

  @override
  List<Object?> get props => [counted, before, activeBefore];
}

class TallyAudioState extends Equatable {
  final TallyAudioPhase phase;
  final TallySessionLimit limit;

  /// Counts made by the voice since the session started.
  final int sessionCount;

  /// Time spent playing in this session (updated after every playback).
  final Duration elapsed;

  /// Set when the session ended on its own; cleared when a new one starts.
  final TallyAudioEnd? endedBecause;

  /// Set when a session that counted something ends (stopped or finished).
  final TallyAudioSummary? summary;

  const TallyAudioState({
    this.phase = TallyAudioPhase.idle,
    this.limit = const TallySessionLimit.endless(),
    this.sessionCount = 0,
    this.elapsed = Duration.zero,
    this.endedBecause,
    this.summary,
  });

  bool get isActive => phase != TallyAudioPhase.idle;

  TallyAudioState copyWith({
    TallyAudioPhase? phase,
    TallySessionLimit? limit,
    int? sessionCount,
    Duration? elapsed,
    TallyAudioEnd? endedBecause,
    TallyAudioSummary? summary,
    bool clearEnd = false,
    bool clearSummary = false,
  }) {
    return TallyAudioState(
      phase: phase ?? this.phase,
      limit: limit ?? this.limit,
      sessionCount: sessionCount ?? this.sessionCount,
      elapsed: elapsed ?? this.elapsed,
      endedBecause: clearEnd ? null : (endedBecause ?? this.endedBecause),
      summary: clearSummary ? null : (summary ?? this.summary),
    );
  }

  @override
  List<Object?> get props => [phase, limit, sessionCount, elapsed, endedBecause, summary];
}

/// Plays the voice recording of the active counter and counts one for every finished
/// playback.
///
/// What happens after a playback follows the tally's auto-advance settings, because
/// the count goes through [TallyBloc] like a tap does: with auto-advance off the same
/// counter goes on; with circular or shuffle it moves to the next counter that has a
/// recording after every count or after a full cycle. A [TallySessionLimit] ends the
/// session. Speed, volume and the pause between playbacks come from the audio
/// settings, which are shared with the zikr viewer.
class TallyAudioCubit extends Cubit<TallyAudioState> {
  final TallyBloc tallyBloc;

  /// Plays the files and holds the shared audio settings (its own player instance).
  final ZikrAudioPlayerCubit engine;
  final TallyRepo repo;
  final CustomAudioStorage storage;

  final Future<void> Function(Duration) _wait;
  final DateTime Function() _now;

  TallyAudioCubit({
    required this.tallyBloc,
    required this.engine,
    required this.repo,
    required this.storage,
    Future<void> Function(Duration)? wait,
    DateTime Function()? now,
  }) : _wait = wait ?? Future<void>.delayed,
       _now = now ?? DateTime.now,
       super(TallyAudioState(limit: repo.getSessionLimit));

  /// Changes whenever the session is paused, stopped or restarted; work that was
  /// waiting for something sees a different value afterwards and gives up.
  int _token = 0;
  Duration _accumulated = Duration.zero;
  DateTime? _since;
  List<DbTally> _before = const [];
  DbTally? _activeBefore;

  TallyAudioSummary? _summary() => state.sessionCount == 0
      ? null
      : TallyAudioSummary(
          counted: state.sessionCount,
          before: _before,
          activeBefore: _activeBefore,
        );

  Future<void> init() {
    return engine.init(
      zikrList: const [],
      autoPlay: false,
      // Every playback counts once, so the player must never repeat on its own.
      getActiveZikrCount: (_) => 1,
      onDonePlaying: (_) => unawaited(_onTrackDone()),
    );
  }

  DbTally? get _active {
    final state = tallyBloc.state;
    return state is TallyLoadedState ? state.activeCounter : null;
  }

  Duration get _elapsed {
    final since = _since;
    return since == null ? _accumulated : _accumulated + _now().difference(since);
  }

  Future<void> setLimit(TallySessionLimit limit) async {
    await repo.saveSessionLimit(limit);
    emit(state.copyWith(limit: limit));
  }

  Future<void> start() async {
    _token++;
    _accumulated = Duration.zero;
    _since = _now();
    final loaded = tallyBloc.state;
    if (loaded is TallyLoadedState) {
      _before = loaded.allCounters;
      _activeBefore = loaded.activeCounter;
    }
    emit(
      state.copyWith(
        phase: TallyAudioPhase.playing,
        sessionCount: 0,
        elapsed: Duration.zero,
        clearEnd: true,
        clearSummary: true,
      ),
    );
    await _playActive(_token);
  }

  Future<void> pause() async {
    if (state.phase != TallyAudioPhase.playing) return;
    _token++;
    _accumulated = _elapsed;
    _since = null;
    await engine.pause();
    emit(state.copyWith(phase: TallyAudioPhase.paused, elapsed: _accumulated));
  }

  Future<void> resume() async {
    if (state.phase != TallyAudioPhase.paused) return;
    final token = ++_token;
    _since = _now();
    emit(state.copyWith(phase: TallyAudioPhase.playing));
    if (engine.state.position > Duration.zero) {
      await engine.resume();
    } else {
      await _playActive(token);
    }
  }

  /// Stops and forgets the session.
  Future<void> stop() async {
    final summary = _summary();
    _token++;
    _since = null;
    _accumulated = Duration.zero;
    await engine.stop();
    emit(
      state.copyWith(
        phase: TallyAudioPhase.idle,
        sessionCount: 0,
        elapsed: Duration.zero,
        clearEnd: true,
        summary: summary,
      ),
    );
  }

  Future<void> _finish(TallyAudioEnd reason) async {
    _token++;
    final elapsed = _elapsed;
    _since = null;
    _accumulated = Duration.zero;
    await engine.stop();
    emit(
      state.copyWith(
        phase: TallyAudioPhase.idle,
        elapsed: elapsed,
        endedBecause: reason,
        summary: _summary(),
      ),
    );
  }

  Future<void> _playActive(int token) async {
    final counter = _active;
    if (counter == null || !counter.hasAudio || !await storage.exists(counter.audioFile)) {
      if (token == _token && !isClosed) await _finish(TallyAudioEnd.noRecording);
      return;
    }
    final path = await storage.pathFor(counter.audioFile);
    if (token != _token || isClosed) return;

    engine.setTrack(_contentOf(counter, path));
    await engine.startPlayFromIndex(0);

    // The player reports a file it could not open by not playing.
    if (token == _token && !isClosed && !engine.state.isPlaying) {
      await _finish(TallyAudioEnd.noRecording);
    }
  }

  DbContent _contentOf(DbTally counter, String path) {
    return DbContent(
      id: counter.id,
      content: counter.title,
      titleId: -1,
      order: 0,
      count: 1,
      fadl: "",
      source: "",
      search: "",
      hokm: "",
      audio: "",
      hasAudio: true,
      userAudioPath: path,
    );
  }

  /// A playback finished: count it, then decide what comes next.
  Future<void> _onTrackDone() async {
    final token = _token;
    if (state.phase != TallyAudioPhase.playing || isClosed) return;

    final completer = Completer<DbTally?>();
    tallyBloc.add(TallyIncreaseActiveCounterEvent(completer: completer, audioOnly: true));
    final next = await completer.future;
    if (token != _token || isClosed) return;

    final counted = state.sessionCount + 1;
    final elapsed = _elapsed;
    emit(state.copyWith(sessionCount: counted, elapsed: elapsed));

    if (state.limit.isReached(counted: counted, elapsed: elapsed)) {
      await _finish(TallyAudioEnd.limitReached);
      return;
    }
    if (next == null || !next.hasAudio) {
      await _finish(TallyAudioEnd.noRecording);
      return;
    }

    await _wait(_pauseBetweenPlaybacks());
    if (token != _token || isClosed) return;

    await _playActive(token);
  }

  /// The pause between two playbacks, as set in the audio settings.
  Duration _pauseBetweenPlaybacks() {
    final audio = engine.state;
    return switch (audio.delayType) {
      AudioDelayTypeEnum.none => Duration.zero,
      AudioDelayTypeEnum.fixedTime => Duration(seconds: audio.delayDuration),
      AudioDelayTypeEnum.byPreviousZikr => Duration(
        milliseconds: (audio.totalDuration.inMilliseconds / audio.playbackSpeed).round(),
      ),
    };
  }

  @override
  Future<void> close() async {
    _token++;
    await engine.close();
    return super.close();
  }
}
