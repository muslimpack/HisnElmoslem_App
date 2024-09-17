// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class DbTitle extends Equatable {
  final int id;
  final String name;
  final int orderId;
  final bool favourite;

  const DbTitle({
    required this.id,
    required this.name,
    required this.orderId,
    required this.favourite,
  });

  factory DbTitle.fromMap(Map<String, dynamic> map) {
    bool favourite;
    if ((map['favourite'] ?? 0) == 0) {
      favourite = false;
    } else {
      favourite = true;
    }
    return DbTitle(
      id: map['id'] as int,
      name: map['name'] as String,
      orderId: map['orderId'] as int,
      // favourite: false,
      favourite: favourite,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'orderId': orderId,
      'favourite': favourite ? 1 : 0,
    };
  }

  @override
  String toString() {
    return toMap().toString();
  }

  @override
  List<Object> get props => [id, name, orderId, favourite];

  DbTitle copyWith({
    int? id,
    String? name,
    int? orderId,
    bool? favourite,
  }) {
    return DbTitle(
      id: id ?? this.id,
      name: name ?? this.name,
      orderId: orderId ?? this.orderId,
      favourite: favourite ?? this.favourite,
    );
  }
}
