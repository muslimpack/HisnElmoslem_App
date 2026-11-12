import 'package:equatable/equatable.dart';

/// Where the audio of one zikr comes from.
sealed class AudioSourceChoice extends Equatable {
  const AudioSourceChoice();

  @override
  List<Object?> get props => [];
}

/// The zikr has nothing to play.
class NoAudio extends AudioSourceChoice {
  const NoAudio();
}

/// A recording made by the user (custom azkar), an absolute file path.
class UserRecording extends AudioSourceChoice {
  final String path;
  const UserRecording(this.path);

  @override
  List<Object?> get props => [path];
}

/// A file bundled in `assets/sounds/azkar`, the name without folder.
class BundledAsset extends AudioSourceChoice {
  final String fileName;
  const BundledAsset(this.fileName);

  @override
  List<Object?> get props => [fileName];
}

/// Files downloaded earlier, played in order (more than one when a zikr spans several lessons).
class DownloadedFiles extends AudioSourceChoice {
  final List<String> paths;
  const DownloadedFiles(this.paths);

  @override
  List<Object?> get props => [paths];
}

/// Remote recordings to stream, played in order.
class StreamUrls extends AudioSourceChoice {
  final List<String> urls;
  const StreamUrls(this.urls);

  @override
  List<Object?> get props => [urls];
}
