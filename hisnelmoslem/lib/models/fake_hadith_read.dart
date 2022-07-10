class DbFakeHadithRead {
  int id;
  int hadithId;
  bool isRead;

  DbFakeHadithRead({
    this.id = 0,
    this.hadithId = 0,
    this.isRead = false,
  });

  factory DbFakeHadithRead.fromMap(Map<String, dynamic> map) {
    return DbFakeHadithRead(
      id: map['_id'],
      hadithId: map['hadith_id'],
      isRead: (map['isRead'] ?? 0) == 0 ? false : true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'title_id': hadithId,
      'isRead': isRead,
    };
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
