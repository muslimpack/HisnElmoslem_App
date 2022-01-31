class DbFakeHaith {
  final int id;

  final String text;
  final String darga;
  final String source;
  final int isRead;
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
