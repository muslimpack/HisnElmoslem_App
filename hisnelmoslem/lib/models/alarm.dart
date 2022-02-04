class DbAlarm {
  int id;
  int titleId;
  String title;
  String body;
  String repeatType;
  int hour;
  int minute;
  int isActive;
  bool hasAlarmInside;

  DbAlarm({
    this.id = 0,
    this.titleId = 0,
    this.title = "",
    this.body = "",
    this.repeatType = "",
    this.hour = 12,
    this.minute = 30,
    this.isActive = 0,
    this.hasAlarmInside = false,
  });

  DbAlarm fromMap(Map<String, dynamic> map) {
    return DbAlarm(
      id: map['id'],
      title: map['title'],
      titleId: map['titleId'],
      body: (map['body'] ?? "") as String,
      repeatType: map['repeatType'],
      hour: map['hour'],
      minute: map['minute'],
      isActive: map['isActive'],
      hasAlarmInside: true,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "id": id,
      "title": title,
      "body": body,
      "repeatType": repeatType,
      "hour": hour,
      "minute": minute,
      "isActive": isActive,
      "titleId": titleId,
    };
  }

  @override
  String toString() {
    return '''
       "id": $id,
      "title": $title,
      "titleId": $titleId,
      "body": $body,
      "repeatType": $repeatType,
      "hour": $hour,
      "minute": $minute,
      "isActive": $isActive,
      "hasAlarmInside": $hasAlarmInside, 
    ''';
  }
}
