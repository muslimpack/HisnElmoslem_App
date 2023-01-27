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
    bool isRead;
    if ((map['isRead'] ?? 0) == 0) {
      isRead = false;
    } else {
      isRead = true;
    }
    return DbFakeHadithRead(
      id: map['_id'] as int,
      hadithId: map['hadith_id'] as int,
      isRead: isRead,
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
