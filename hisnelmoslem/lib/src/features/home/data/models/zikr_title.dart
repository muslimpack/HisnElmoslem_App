// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class DbTitle extends Equatable {
  final int id;
  final String name;
  final String freq;
  final int order;

  const DbTitle({
    required this.id,
    required this.name,
    required this.freq,
    required this.order,
  });

  factory DbTitle.fromMap(Map<String, dynamic> map) {
    return DbTitle(
      id: map['id'] as int,
      name: map['name'] as String,
      freq: map['freq'] as String,
      order: map['order'] as int,
    );
  }

  @override
  List<Object> get props {
    return [id, name, freq, order];
  }

  DbTitle copyWith({int? id, String? name, String? freq, int? order}) {
    return DbTitle(
      id: id ?? this.id,
      name: name ?? this.name,
      freq: freq ?? this.freq,
      order: order ?? this.order,
    );
  }
}
