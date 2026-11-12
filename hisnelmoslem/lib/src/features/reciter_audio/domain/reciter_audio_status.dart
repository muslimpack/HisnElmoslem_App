import 'package:equatable/equatable.dart';

/// How much of a reciter's recordings is on the phone.
class ReciterAudioStatus extends Equatable {
  final int totalFiles;
  final int downloadedFiles;
  final int downloadedBytes;

  const ReciterAudioStatus({
    this.totalFiles = 0,
    this.downloadedFiles = 0,
    this.downloadedBytes = 0,
  });

  bool get hasDownloads => downloadedFiles > 0;
  bool get isComplete => totalFiles > 0 && downloadedFiles >= totalFiles;

  @override
  List<Object?> get props => [totalFiles, downloadedFiles, downloadedBytes];
}
