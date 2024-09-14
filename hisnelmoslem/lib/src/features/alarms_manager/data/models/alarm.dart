import 'package:equatable/equatable.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/alarm_repeat_type.dart';

class DbAlarm extends Equatable {
  final int id;
  final int titleId;
  final String title;
  final String body;
  final AlarmRepeatType repeatType;
  final int hour;
  final int minute;
  final bool isActive;
  final bool hasAlarmInside;

  const DbAlarm({
    this.id = 0,
    required this.titleId,
    required this.title,
    this.body = "",
    this.repeatType = AlarmRepeatType.daily,
    this.hour = 12,
    this.minute = 30,
    this.isActive = false,
    this.hasAlarmInside = false,
  });

  factory DbAlarm.fromMap(Map<String, dynamic> map) {
    bool isActive;
    if ((map['isActive'] ?? 0) == 0) {
      isActive = false;
    } else {
      isActive = true;
    }

    final repeatTypeString = map['repeatType'] as String;
    final repeatType = AlarmRepeatType.values
            .where(
              (x) => x.name.toLowerCase() == repeatTypeString.toLowerCase(),
            )
            .firstOrNull ??
        AlarmRepeatType.daily;

    return DbAlarm(
      id: map['id'] as int,
      title: map['title'] as String,
      titleId: map['titleId'] as int,
      body: (map['body'] ?? "") as String,
      repeatType: repeatType,
      hour: map['hour'] as int,
      minute: map['minute'] as int,
      isActive: isActive,
      hasAlarmInside: true,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "title": title,
      "body": body,
      "repeatType": repeatType.name,
      "hour": hour,
      "minute": minute,
      "isActive": isActive ? 1 : 0,
      "titleId": titleId,
    };
  }

  @override
  String toString() {
    return toMap().toString();
  }

  DbAlarm copyWith({
    int? id,
    int? titleId,
    String? title,
    String? body,
    AlarmRepeatType? repeatType,
    int? hour,
    int? minute,
    bool? isActive,
    bool? hasAlarmInside,
  }) {
    return DbAlarm(
      id: id ?? this.id,
      titleId: titleId ?? this.titleId,
      title: title ?? this.title,
      body: body ?? this.body,
      repeatType: repeatType ?? this.repeatType,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      isActive: isActive ?? this.isActive,
      hasAlarmInside: hasAlarmInside ?? this.hasAlarmInside,
    );
  }

  @override
  List<Object> get props {
    return [
      id,
      titleId,
      title,
      body,
      repeatType,
      hour,
      minute,
      isActive,
      hasAlarmInside,
    ];
  }
}
