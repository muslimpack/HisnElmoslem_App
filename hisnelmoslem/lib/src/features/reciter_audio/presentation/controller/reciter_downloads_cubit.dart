import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/data/audio_file_store.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/data/http_audio_downloader.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/data/reciter_audio_repo.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/download_plan.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/reciter.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/reciter_audio_status.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/controller/reciter_downloads_state.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

/// Downloads the recordings of a reciter, or of one title of it, one job at a time.
///
/// Only zikrs marked [DbContent.audioRemoteOk] are fetched. Finished files stay when a job is
/// paused, cancelled or interrupted, and a `.part` file is continued by the next run.
class ReciterDownloadsCubit extends Cubit<ReciterDownloadsState> {
  final AudioDownloader downloader;
  final AudioFileStore store;
  final ReciterAudioRepo repo;

  /// The contents of [titleId], or of every title when it is null.
  final Future<List<DbContent>> Function({int? titleId}) loadContents;

  /// Files downloaded at the same time.
  final int parallel;

  ReciterDownloadsCubit({
    required this.downloader,
    required this.store,
    required this.repo,
    required this.loadContents,
    this.parallel = 3,
  }) : super(const ReciterDownloadsState());

  DownloadCancelToken? _token;
  bool _removeJobWhenStopped = false;

  /// Every file [reciter] has for the zikrs that may use remote audio (one per lesson).
  Future<List<String>> _urlsOf(Reciter reciter, {int? titleId}) async {
    final contents = await loadContents(titleId: titleId);

    final seen = <String>{};
    final urls = <String>[];
    for (final c in contents) {
      if (!c.audioRemoteOk) continue;
      for (final url in c.audioUrls[reciter.slug] ?? const <String>[]) {
        if (seen.add(AudioFileStore.keyOf(url))) urls.add(url);
      }
    }
    return urls;
  }

  /// How much of [reciter] is on the phone. No network is used.
  Future<ReciterAudioStatus> statusOf(Reciter reciter, {int? titleId}) async {
    final urls = await _urlsOf(reciter, titleId: titleId);
    var done = 0;
    var bytes = 0;
    for (final url in urls) {
      final file = await store.fileOf(reciter, url);
      if (await file.exists()) {
        final length = await file.length();
        if (length > 0) {
          done++;
          bytes += length;
        }
      }
    }
    return ReciterAudioStatus(
      totalFiles: urls.length,
      downloadedFiles: done,
      downloadedBytes: bytes,
    );
  }

  /// What is still missing for [reciter] (and [titleId] when given), with the size the server
  /// reports for those files.
  Future<DownloadPlan> buildPlan(Reciter reciter, {int? titleId}) async {
    final urls = await _urlsOf(reciter, titleId: titleId);

    final pending = <String>[];
    for (final url in urls) {
      if (await store.existingPath(reciter, url) == null) pending.add(url);
    }

    var bytes = 0;
    var unknown = 0;
    for (var i = 0; i < pending.length; i += 6) {
      final batch = pending.skip(i).take(6);
      final sizes = await Future.wait(batch.map(downloader.contentLength));
      for (final size in sizes) {
        if (size == null) {
          unknown++;
        } else {
          bytes += size;
        }
      }
    }

    return DownloadPlan(
      reciter: reciter,
      titleId: titleId,
      pendingUrls: pending,
      alreadyDownloaded: urls.length - pending.length,
      pendingBytes: bytes,
      unknownSizes: unknown,
    );
  }

  /// Shows an interrupted job (the app was closed while it ran) as paused, so the user can
  /// resume it. Does nothing while a job is running.
  void restore() {
    if (state.isRunning) return;
    final job = repo.loadJob();
    if (job == null) return;
    emit(
      ReciterDownloadsState(
        status: DownloadStatus.paused,
        reciter: job.reciter,
        titleId: job.titleId,
      ),
    );
  }

  /// Runs [plan] and completes when every file was tried, or the job was paused or cancelled.
  Future<void> start(DownloadPlan plan) async {
    if (state.isRunning) return;
    _token = DownloadCancelToken();
    _removeJobWhenStopped = false;
    final token = _token!;

    final failed = <String>[];
    final received = <String, int>{};
    var done = plan.alreadyDownloaded;
    final totalBytes = plan.unknownSizes == 0 ? plan.pendingBytes : null;
    final throttle = Stopwatch()..start();

    ReciterDownloadsState snapshot(DownloadStatus status) => ReciterDownloadsState(
      status: status,
      reciter: plan.reciter,
      titleId: plan.titleId,
      totalFiles: plan.totalFiles,
      doneFiles: done,
      failedUrls: List.of(failed),
      receivedBytes: received.values.fold<int>(0, (a, b) => a + b),
      totalBytes: totalBytes,
    );

    await repo.saveJob(plan.reciter, plan.titleId);
    emit(snapshot(DownloadStatus.running));

    var next = 0;
    Future<void> worker() async {
      while (!token.isCancelled) {
        final index = next++;
        if (index >= plan.pendingUrls.length) return;
        final url = plan.pendingUrls[index];
        try {
          await downloader.download(
            url: url,
            target: await store.fileOf(plan.reciter, url),
            cancel: token,
            onProgress: (bytes, _) {
              received[url] = bytes;
              if (throttle.elapsedMilliseconds >= 150 && !isClosed) {
                throttle.reset();
                emit(snapshot(DownloadStatus.running));
              }
            },
          );
          done++;
        } on DownloadCancelled {
          return;
        } catch (e) {
          hisnPrint('download failed $url: $e');
          failed.add(url);
        }
        if (!isClosed) emit(snapshot(DownloadStatus.running));
      }
    }

    await Future.wait([for (var i = 0; i < parallel; i++) worker()]);
    if (isClosed) return;

    if (token.isCancelled) {
      if (_removeJobWhenStopped) {
        await repo.clearJob();
        emit(const ReciterDownloadsState());
      } else {
        emit(snapshot(DownloadStatus.paused));
      }
    } else {
      await repo.clearJob();
      emit(snapshot(DownloadStatus.completed));
    }
  }

  /// Stops the running job. The files finished so far stay and [resume] continues.
  void pause() => _token?.cancel();

  /// Stops the running job and forgets it (a paused job is forgotten too). Files stay on the phone.
  Future<void> cancel() async {
    if (state.isRunning) {
      _removeJobWhenStopped = true;
      _token?.cancel();
      return;
    }
    await repo.clearJob();
    emit(const ReciterDownloadsState());
  }

  /// Continues the paused job, or retries the files that failed, with a fresh plan.
  Future<void> resume() async {
    final reciter = state.reciter;
    if (reciter == null || state.isRunning) return;
    final plan = await buildPlan(reciter, titleId: state.titleId);
    if (plan.isEmpty) {
      await repo.clearJob();
      emit(
        ReciterDownloadsState(
          status: DownloadStatus.completed,
          reciter: reciter,
          titleId: state.titleId,
          totalFiles: plan.totalFiles,
          doneFiles: plan.totalFiles,
        ),
      );
      return;
    }
    await start(plan);
  }

  @override
  Future<void> close() {
    _token?.cancel();
    return super.close();
  }
}
