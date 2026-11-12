import 'package:equatable/equatable.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/reciter.dart';

enum DownloadStatus {
  /// Nothing is running and nothing is waiting to be resumed.
  idle,
  running,

  /// Stopped by the user or by closing the app; the finished files stay and a resume continues.
  paused,

  /// Every file was tried. [ReciterDownloadsState.failedUrls] lists the ones that failed.
  completed,
}

class ReciterDownloadsState extends Equatable {
  final DownloadStatus status;
  final Reciter? reciter;

  /// Null means the whole reciter.
  final int? titleId;
  final int totalFiles;
  final int doneFiles;
  final List<String> failedUrls;

  /// Bytes received in this run, and the bytes expected when the server told us.
  final int receivedBytes;
  final int? totalBytes;

  const ReciterDownloadsState({
    this.status = DownloadStatus.idle,
    this.reciter,
    this.titleId,
    this.totalFiles = 0,
    this.doneFiles = 0,
    this.failedUrls = const [],
    this.receivedBytes = 0,
    this.totalBytes,
  });

  bool get isRunning => status == DownloadStatus.running;

  /// 0..1 by files; 0 when there is nothing to do.
  double get fileProgress => totalFiles == 0 ? 0 : doneFiles / totalFiles;

  ReciterDownloadsState copyWith({
    DownloadStatus? status,
    Reciter? reciter,
    int? titleId,
    int? totalFiles,
    int? doneFiles,
    List<String>? failedUrls,
    int? receivedBytes,
    int? totalBytes,
  }) {
    return ReciterDownloadsState(
      status: status ?? this.status,
      reciter: reciter ?? this.reciter,
      titleId: titleId ?? this.titleId,
      totalFiles: totalFiles ?? this.totalFiles,
      doneFiles: doneFiles ?? this.doneFiles,
      failedUrls: failedUrls ?? this.failedUrls,
      receivedBytes: receivedBytes ?? this.receivedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
    );
  }

  @override
  List<Object?> get props => [
    status,
    reciter,
    titleId,
    totalFiles,
    doneFiles,
    failedUrls,
    receivedBytes,
    totalBytes,
  ];
}
