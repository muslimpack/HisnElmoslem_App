// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class ZikrSession extends Equatable {
  final int version;
  final DateTime dateTime;
  final Map<int, int> data;

  const ZikrSession({
    this.version = 2,
    required this.dateTime,
    required this.data,
  });

  @override
  List<Object> get props => [version, dateTime, data];

  ZikrSession copyWith({
    int? version,
    DateTime? dateTime,
    Map<int, int>? data,
  }) {
    return ZikrSession(
      version: version ?? this.version,
      dateTime: dateTime ?? this.dateTime,
      data: data ?? this.data,
    );
  }

  String toJson() {
    return json.encode(<String, dynamic>{
      'version': version,
      'dateTime': dateTime.toIso8601String(),
      'data': data.map((key, value) => MapEntry(key.toString(), value)),
    });
  }

  factory ZikrSession.fromJson(String source) {
    final decodedJson = json.decode(source);
    if (decodedJson is Map<String, dynamic>) {
      if (decodedJson.containsKey('version')) {
        if (decodedJson['version'] == 2) {
          final version = decodedJson['version'] as int;
          final dateTime = DateTime.parse(decodedJson['dateTime'] as String);
          final sessionData = decodedJson["data"] as Map<String, dynamic>;
          final data = sessionData.map(
            (key, value) => MapEntry(int.parse(key), value as int),
          );
          return ZikrSession(version: version, dateTime: dateTime, data: data);
        }
      } else {
        const version = 1;
        final dateTime = DateTime.now();
        final sessionData = decodedJson["data"] as Map<String, dynamic>;
        final data = sessionData.map(
          (key, value) => MapEntry(int.parse(key), value as int),
        );
        return ZikrSession(version: version, dateTime: dateTime, data: data);
      }
    }
    throw const FormatException("Unsupported zikr session format");
  }
}
