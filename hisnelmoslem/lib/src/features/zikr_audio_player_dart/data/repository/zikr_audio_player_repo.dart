import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player_dart/data/models/audio_delay_type_enum.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player_dart/data/models/audio_repeat_type_enum.dart';

class ZikrAudioPlayerRepo {
  final GetStorage box;
  ZikrAudioPlayerRepo(this.box);

  static const String speedKey = 'audio_speed';
  static const String volumeKey = 'audio_volume';
  static const String repeatKey = 'audio_repeat';
  static const String delayKey = 'audio_delay';

  double getSpeed() => box.read(speedKey) ?? 1.0;
  double getVolume() => box.read(volumeKey) ?? 1.0;
  AudioDelayTypeEnum getDelay() =>
      AudioDelayTypeEnum.values.byName(box.read(delayKey) ?? AudioDelayTypeEnum.none.name);
  AudioRepeatTypeEnum getRepeat() => AudioRepeatTypeEnum.values.byName(
    box.read(repeatKey) ?? AudioRepeatTypeEnum.byZikrCount.name,
  );

  Future<void> saveSettings({
    double? speed,
    double? volume,
    AudioRepeatTypeEnum? repeat,
    AudioDelayTypeEnum? delay,
  }) async {
    if (speed != null) box.write(speedKey, speed);
    if (volume != null) box.write(volumeKey, volume);
    if (repeat != null) box.write(repeatKey, repeat.name);
    if (delay != null) box.write(delayKey, delay.name);
  }
}
