import 'package:hisnelmoslem/src/features/reciter_audio/domain/audio_source_choice.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/reciter.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

/// Chooses the audio source of a zikr. Pure logic: the file system and the network are
/// passed in, so it can be tested without them.
///
/// Order: the user's recording, the bundled file, downloaded files, then streaming when
/// [isOnline]. Zikrs that are not [DbContent.audioRemoteOk] never use remote recordings.
class AudioSourceResolver {
  /// Absolute path of the downloaded file of [url] for [reciter], or null when it is not there.
  final String? Function(Reciter reciter, String url) downloadedPath;
  final bool Function() isOnline;

  const AudioSourceResolver({required this.downloadedPath, required this.isOnline});

  AudioSourceChoice resolve(DbContent zikr, Reciter reciter) {
    if (zikr.userAudioPath.isNotEmpty) return UserRecording(zikr.userAudioPath);

    final remote = zikr.audioRemoteOk ? zikr.audioUrls[reciter.slug] : null;
    final hasRemote = remote != null && remote.isNotEmpty;

    // The bundled recordings are the owner's trimmed ones of the bundled reciter. A zikr
    // without a usable remote recording keeps them whatever reciter is selected, so no zikr
    // falls silent.
    if (zikr.audio.isNotEmpty && (reciter.isBundled || !hasRemote)) {
      return BundledAsset(zikr.audio);
    }

    if (!hasRemote) return const NoAudio();

    final local = <String>[];
    for (final url in remote) {
      final path = downloadedPath(reciter, url);
      if (path == null) break;
      local.add(path);
    }
    if (local.length == remote.length) return DownloadedFiles(local);

    return isOnline() ? StreamUrls(remote) : const NoAudio();
  }
}
