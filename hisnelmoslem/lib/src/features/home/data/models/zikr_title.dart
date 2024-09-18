// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class DbTitle extends Equatable {
  final int id;
  final String name;
  final String freq;
  final int orderId;
  final bool favourite;

  const DbTitle({
    required this.id,
    required this.name,
    required this.freq,
    required this.orderId,
    required this.favourite,
  });

  factory DbTitle.fromMap(Map<String, dynamic> map) {
    return DbTitle(
      id: map['id'] as int,
      name: map['name'] as String,
      freq: map['freq'] as String,
      orderId: map['orderId'] as int,
      favourite: false,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'freq': freq,
      'orderId': orderId,
    };
  }

  @override
  String toString() {
    return toMap().toString();
  }

  @override
  List<Object> get props {
    return [
      id,
      name,
      freq,
      orderId,
      favourite,
    ];
  }

  DbTitle copyWith({
    int? id,
    String? name,
    String? freq,
    int? orderId,
    bool? favourite,
  }) {
    return DbTitle(
      id: id ?? this.id,
      name: name ?? this.name,
      freq: freq ?? this.freq,
      orderId: orderId ?? this.orderId,
      favourite: favourite ?? this.favourite,
    );
  }
}
