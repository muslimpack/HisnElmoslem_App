class DbFakeHaith {
  int id;
  String text;
  String darga;
  String source;
  bool isRead;

  DbFakeHaith({
    this.id = 0,
    this.text = "",
    this.darga = "",
    this.source = "",
    this.isRead = false,
  });

  factory DbFakeHaith.fromMap(Map<String, dynamic> map) {
    bool isRead;
    if ((map['isRead'] ?? 0) == 0) {
      isRead = false;
    } else {
      isRead = true;
    }
    return DbFakeHaith(
      id: map['_id'] as int,
      source: map['source'] as String,
      text: (map['text'] as String).replaceAll("\\n", "\n"),
      darga: (map['darga'] as String).replaceAll("\\n", "\n"),
      isRead: isRead,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': id,
      'text': text,
      'darga': darga,
      'source': source,
      'isRead': isRead ? 1 : 0,
    };
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
