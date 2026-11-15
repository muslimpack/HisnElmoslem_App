import 'package:get_storage/get_storage.dart';

class AlarmsRepo {
  final GetStorage box;

  AlarmsRepo(this.box);

  /* ******* Surat al kahf alarm ******* */

  bool get isCaveAlarmEnabled => box.read('cave_status') ?? false;

  Future<void> changCaveAlarmStatus({required bool value}) async {
    await box.write('cave_status', value);
  }

  void toggleCaveAlarmStatus() {
    changCaveAlarmStatus(value: !isCaveAlarmEnabled);
  }

  /* ******* monday and thursday fast alarm ******* */

  bool get isFastAlarmEnabled => box.read('fast_status') ?? false;

  Future<void> changFastAlarmStatus({required bool value}) async {
    await box.write('fast_status', value);
  }

  void toggleFastAlarmStatus() {
    changFastAlarmStatus(value: !isFastAlarmEnabled);
  }

  /// Time of day of the fasting reminders (default 20:00).
  int get fastAlarmHour => box.read('fast_hour') ?? 20;
  int get fastAlarmMinute => box.read('fast_minute') ?? 0;

  /// `false`: the evening before the fast. `true`: on the fasting day itself.
  bool get fastAlarmSameDay => box.read('fast_same_day') ?? false;

  Future<void> changeFastSchedule({
    required int hour,
    required int minute,
    required bool sameDay,
  }) async {
    await box.write('fast_hour', hour);
    await box.write('fast_minute', minute);
    await box.write('fast_same_day', sameDay);
  }
}
