import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/reciter.dart';

class ReciterAudioRepo {
  final GetStorage box;
  ReciterAudioRepo(this.box);

  static const String reciterKey = 'audio_reciter';
  static const String allowStreamKey = 'audio_allow_stream';
  static const String jobKey = 'audio_download_job';

  Reciter getReciter() {
    try {
      return Reciter.bySlug(box.read(reciterKey) as String?) ?? Reciter.defaultReciter;
    } catch (_) {
      return Reciter.defaultReciter;
    }
  }

  Future<void> setReciter(Reciter reciter) => box.write(reciterKey, reciter.slug);

  /// The job that was running when the app closed, so it can be offered again.
  ({Reciter reciter, int? titleId})? loadJob() {
    try {
      final raw = box.read(jobKey);
      if (raw is! Map) return null;
      final reciter = Reciter.bySlug(raw['reciter'] as String?);
      if (reciter == null) return null;
      return (reciter: reciter, titleId: raw['titleId'] as int?);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveJob(Reciter reciter, int? titleId) =>
      box.write(jobKey, {'reciter': reciter.slug, 'titleId': titleId});

  Future<void> clearJob() => box.remove(jobKey);

  /// Whether recordings that are not on the phone may be streamed. Defaults to on.
  bool getAllowStream() {
    try {
      return box.read(allowStreamKey) as bool? ?? true;
    } catch (_) {
      return true;
    }
  }

  Future<void> setAllowStream(bool value) => box.write(allowStreamKey, value);
}
