// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class DbTally extends Equatable {
  final int id;
  final String title;
  final int count;
  final int countReset;
  final DateTime created;
  final DateTime lastUpdate;
  final bool isActivated;

  const DbTally({
    this.id = -1,
    required this.title,
    required this.count,
    required this.countReset,
    required this.isActivated,
    required this.created,
    required this.lastUpdate,
  });

  const DbTally.empty({
    this.id = -1,
    this.title = "",
    this.count = 0,
    this.countReset = 33,
    this.isActivated = false,
    required this.created,
    required this.lastUpdate,
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

  DbTally copyWith({
    int? id,
    String? title,
    int? count,
    int? countReset,
    DateTime? created,
    DateTime? lastUpdate,
    bool? isActivated,
  }) {
    return DbTally(
      id: id ?? this.id,
      title: title ?? this.title,
      count: count ?? this.count,
      countReset: countReset ?? this.countReset,
      created: created ?? this.created,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      isActivated: isActivated ?? this.isActivated,
    );
  }

  @override
  List<Object> get props {
    return [
      id,
      title,
      count,
      countReset,
      created,
      lastUpdate,
      isActivated,
    ];
  }
}
