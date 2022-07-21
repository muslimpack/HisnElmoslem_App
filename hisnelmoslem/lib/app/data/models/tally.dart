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
    return DbTally(
      id: map['id'],
      title: map['title'],
      count: map['count'],
      countReset: map['countReset'],
      isActivated: (map['isActivated'] ?? 0) == 0 ? false : true,
      created: DateTime.parse(map['created']),
      lastUpdate: DateTime.parse(map['lastUpdate']),
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
