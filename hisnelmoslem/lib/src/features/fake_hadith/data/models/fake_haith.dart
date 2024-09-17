// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class DbFakeHaith extends Equatable {
  final int id;
  final String text;
  final String darga;
  final String source;
  final bool isRead;

  const DbFakeHaith({
    required this.id,
    required this.text,
    required this.darga,
    required this.source,
    required this.isRead,
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

  DbFakeHaith copyWith({
    int? id,
    String? text,
    String? darga,
    String? source,
    bool? isRead,
  }) {
    return DbFakeHaith(
      id: id ?? this.id,
      text: text ?? this.text,
      darga: darga ?? this.darga,
      source: source ?? this.source,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object> get props {
    return [
      id,
      text,
      darga,
      source,
      isRead,
    ];
  }
}
