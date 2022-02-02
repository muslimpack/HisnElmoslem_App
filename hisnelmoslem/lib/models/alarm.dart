class DbAlarm {
  int id;
  int titleId;
  String title;
  String? body;
  String repeatType;
  int hour;
  int minute;
  int isActive;
  bool hasAlarmInside;

  DbAlarm({
    required this.id,
    required this.titleId,
    this.title = "",
    this.body = "",
    this.repeatType = "",
    this.hour = 12,
    this.minute = 30,
    this.isActive = 0,
    this.hasAlarmInside = false,
  });

  //
  // DbTitle.fromMap(Map<String, dynamic> map) {
  //   id: map['_id'];
  //   name: map['name'];
  //   chapter_id: map['chapter_id'];
  //   order_id: map['order_id'];
  //   favourite: map['favourite'];
  // }

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
