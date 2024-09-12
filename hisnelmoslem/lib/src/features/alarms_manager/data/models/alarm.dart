// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

/// TODO make final fields after removeing GetX
class DbAlarm extends Equatable {
  int id;
  int titleId;
  String title;
  String body;
  String repeatType;
  int hour;
  int minute;
  bool isActive;
  bool hasAlarmInside;

  DbAlarm({
    this.id = 0,
    this.titleId = 0,
    this.title = "",
    this.body = "",
    this.repeatType = "",
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
    return DbAlarm(
      id: map['id'] as int,
      title: map['title'] as String,
      titleId: map['titleId'] as int,
      body: (map['body'] ?? "") as String,
      repeatType: map['repeatType'] as String,
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
      "repeatType": repeatType,
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
    String? repeatType,
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
