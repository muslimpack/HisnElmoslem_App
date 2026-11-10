import 'package:flutter_test/flutter_test.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/data/services/custom_alarm_scheduler.dart';

void main() {
  group("custom alarm payload", () {
    test("round trips the title id", () {
      final payload = CustomAlarmScheduler.payloadFor(42);
      expect(payload, "custom:42");
      expect(CustomAlarmScheduler.titleIdFromPayload(payload), 42);
    });

    test("ignores payloads of original alarms and special alarms", () {
      expect(CustomAlarmScheduler.titleIdFromPayload("12"), isNull);
      expect(CustomAlarmScheduler.titleIdFromPayload("555"), isNull);
      expect(CustomAlarmScheduler.titleIdFromPayload("الكهف"), isNull);
      expect(CustomAlarmScheduler.titleIdFromPayload("custom:abc"), isNull);
    });
  });

  test("notification ids never collide with original or reserved ids", () {
    expect(CustomAlarmScheduler.notificationId(1), greaterThan(100000));
    expect(CustomAlarmScheduler.notificationId(1), isNot(555));
    expect(CustomAlarmScheduler.notificationId(1), isNot(666));
  });
}
