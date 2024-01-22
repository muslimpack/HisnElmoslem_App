class DbAlarm {
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
}
