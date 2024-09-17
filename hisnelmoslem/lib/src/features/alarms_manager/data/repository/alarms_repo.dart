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
}
