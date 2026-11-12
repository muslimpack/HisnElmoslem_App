import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/reciter.dart';

class ReciterAudioRepo {
  final GetStorage box;
  ReciterAudioRepo(this.box);

  static const String reciterKey = 'audio_reciter';

  Reciter getReciter() {
    try {
      return Reciter.bySlug(box.read(reciterKey) as String?) ?? Reciter.defaultReciter;
    } catch (_) {
      return Reciter.defaultReciter;
    }
  }

  Future<void> setReciter(Reciter reciter) => box.write(reciterKey, reciter.slug);
}
