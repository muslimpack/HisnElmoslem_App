// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class DbTitle extends Equatable {
  final int id;
  final String name;
  final String freq;
  final int order;

  /// Diacritics-free text of the title used for searching (empty if unknown).
  final String search;

  const DbTitle({
    required this.id,
    required this.name,
    required this.freq,
    required this.order,
    this.search = "",
  });

  factory DbTitle.fromMap(Map<String, dynamic> map) {
    return DbTitle(
      id: map['id'] as int,
      name: map['name'] as String,
      freq: map['freq'] as String,
      order: map['order'] as int,
      search: (map['search'] as String?) ?? "",
    );
  }

  @override
  List<Object> get props {
    return [id, name, freq, order, search];
  }

  DbTitle copyWith({int? id, String? name, String? freq, int? order, String? search}) {
    return DbTitle(
      id: id ?? this.id,
      name: name ?? this.name,
      freq: freq ?? this.freq,
      order: order ?? this.order,
      search: search ?? this.search,
    );
  }
}
