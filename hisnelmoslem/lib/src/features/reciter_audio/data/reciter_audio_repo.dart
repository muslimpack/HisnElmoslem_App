import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/reciter.dart';

class ReciterAudioRepo {
  final GetStorage box;
  ReciterAudioRepo(this.box);

  static const String reciterKey = 'audio_reciter';
  static const String allowStreamKey = 'audio_allow_stream';

  Reciter getReciter() {
    try {
      return Reciter.bySlug(box.read(reciterKey) as String?) ?? Reciter.defaultReciter;
    } catch (_) {
      return Reciter.defaultReciter;
    }
  }

  Future<void> setReciter(Reciter reciter) => box.write(reciterKey, reciter.slug);

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
