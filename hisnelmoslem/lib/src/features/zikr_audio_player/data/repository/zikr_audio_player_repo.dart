import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/data/models/audio_delay_type_enum.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/data/models/audio_repeat_type_enum.dart';

class ZikrAudioPlayerRepo {
  final GetStorage box;
  ZikrAudioPlayerRepo(this.box);

  static const String speedKey = 'audio_speed';
  static const String volumeKey = 'audio_volume';
  static const String repeatKey = 'audio_repeat';
  static const String delayKey = 'audio_delay';
  static const String delayDurationKey = 'audio_delay_duration';

  double getSpeed() {
    try {
      final val = box.read(speedKey);
      if (val is num) {
        final speed = val.toDouble();
        return speed < 0.5 ? 1.0 : speed;
      }
      return 1.0;
    } catch (_) {
      return 1.0;
    }
  }

  double getVolume() {
    try {
      final val = box.read(volumeKey);
      if (val is num) return val.toDouble();
      return 1.0;
    } catch (_) {
      return 1.0;
    }
  }

  AudioDelayTypeEnum getDelay() {
    try {
      final val = box.read(delayKey);
      if (val is String) {
        return AudioDelayTypeEnum.values.byName(val);
      }
      return AudioDelayTypeEnum.fixedTime;
    } catch (_) {
      return AudioDelayTypeEnum.fixedTime;
    }
  }

  int getDelayDuration() {
    try {
      final val = box.read(delayDurationKey);
      if (val is num) return val.toInt();
      return 1;
    } catch (_) {
      return 1;
    }
  }

  AudioRepeatTypeEnum getRepeat() {
    try {
      final val = box.read(repeatKey);
      if (val is String) {
        return AudioRepeatTypeEnum.values.byName(val);
      }
      return AudioRepeatTypeEnum.byZikrCount;
    } catch (_) {
      return AudioRepeatTypeEnum.byZikrCount;
    }
  }

  Future<void> saveSettings({
    double? speed,
    double? volume,
    AudioRepeatTypeEnum? repeat,
    AudioDelayTypeEnum? delay,
    int? delayDuration,
  }) async {
    if (speed != null) box.write(speedKey, speed);
    if (volume != null) box.write(volumeKey, volume);
    if (repeat != null) box.write(repeatKey, repeat.name);
    if (delay != null) box.write(delayKey, delay.name);
    if (delayDuration != null) box.write(delayDurationKey, delayDuration);
  }
}
