import 'package:equatable/equatable.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/alarm_repeat_type.dart';

/// One alarm per custom title. Tapping its notification opens the title.
class CustomAlarm extends Equatable {
  final int id;
  final int titleId;
  final String body;
  final AlarmRepeatType repeatType;
  final int hour;
  final int minute;
  final bool isActive;

  const CustomAlarm({
    this.id = 0,
    required this.titleId,
    this.body = "",
    this.repeatType = AlarmRepeatType.daily,
    this.hour = 12,
    this.minute = 30,
    this.isActive = false,
  });

  CustomAlarm copyWith({
    int? id,
    String? body,
    AlarmRepeatType? repeatType,
    int? hour,
    int? minute,
    bool? isActive,
  }) {
    return CustomAlarm(
      id: id ?? this.id,
      titleId: titleId,
      body: body ?? this.body,
      repeatType: repeatType ?? this.repeatType,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object> get props => [id, titleId, body, repeatType, hour, minute, isActive];
}
