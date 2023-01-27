class DbTally {
  int id;
  String title;
  int count;
  int countReset;
  DateTime? created;
  DateTime? lastUpdate;
  bool isActivated;

  DbTally({
    this.id = 0,
    this.title = "بلا اسم",
    this.count = 0,
    this.countReset = 33,
    this.isActivated = false,
    this.created,
    this.lastUpdate,
  });

  factory DbTally.fromMap(Map<String, dynamic> map) {
    bool isActivated;
    if ((map['isActivated'] ?? 0) == 0) {
      isActivated = false;
    } else {
      isActivated = true;
    }
    return DbTally(
      id: map['id'] as int,
      title: map['title'] as String,
      count: map['count'] as int,
      countReset: map['countReset'] as int,
      isActivated: isActivated,
      created: DateTime.parse(map['created'] as String),
      lastUpdate: DateTime.parse(map['lastUpdate'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "title": title,
      "count": count,
      "countReset": countReset,
      "isActivated": isActivated ? 1 : 0,
      "created": created.toString(),
      "lastUpdate": lastUpdate.toString(),
    };
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
