
class DbAlarm {
  int id;
  String title;
  String body;
  String repeatType;
  int hour;
  int minute;
  int isActive;

  DbAlarm({
    required this.id,
    required this.title,
    required this.body,
    required this.repeatType,
    required this.hour,
    required this.minute,
    required this.isActive,
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
    };
  }
}
