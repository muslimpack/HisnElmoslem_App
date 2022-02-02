class DbFakeHaith {
  int id;

  String text;
  String darga;
  String source;
  int isRead;
  DbFakeHaith({
    required this.id,
    required this.text,
    required this.darga,
    required this.source,
    required this.isRead,
  });

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
