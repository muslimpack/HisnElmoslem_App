class DbFakeHaith {
  int id;
  String text;
  String darga;
  String source;
  int isRead;

  DbFakeHaith({
    this.id = 0,
    this.text = "",
    this.darga = "",
    this.source = "",
    this.isRead = 0,
  });

  DbFakeHaith fromMap(Map<String, dynamic> map) {
    return DbFakeHaith(
      id: map['_id'],
      source: map['source'],
      text: (map['text'] as String).replaceAll("\\n", "\n"),
      darga: (map['darga'] as String).replaceAll("\\n", "\n"),
      isRead: map['isRead'],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': id,
      'text': text,
      'darga': darga,
      'source': source,
      'isRead': isRead,
    };
  }

  @override
  String toString() {
    return '''
      '_id': $id,
      'text': $text,
      'darga': $darga,
      'source': $source,
      'isRead': $isRead,
    ''';
  }
}
