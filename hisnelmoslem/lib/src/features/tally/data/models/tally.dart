// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class DbTally extends Equatable {
  final int id;
  final String title;
  final int count;

  /// The size of one full cycle (33 for the usual tasbih).
  final int countReset;
  final DateTime created;
  final DateTime lastUpdate;
  final bool isActivated;

  /// Name of the user's voice recording for this counter, empty when it has none.
  final String audioFile;

  const DbTally({
    this.id = -1,
    required this.title,
    required this.count,
    required this.countReset,
    required this.isActivated,
    required this.created,
    required this.lastUpdate,
    this.audioFile = "",
  });

  const DbTally.empty({
    this.id = -1,
    this.title = "",
    this.count = 0,
    this.countReset = 33,
    this.isActivated = false,
    this.audioFile = "",
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
      audioFile: (map['audioFile'] as String?) ?? "",
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
      "audioFile": audioFile,
    };
  }

  bool get hasAudio => audioFile.isNotEmpty;

  /// The size of a cycle, never below 1 so it is safe to divide by.
  int get cycleSize => countReset < 1 ? 1 : countReset;

  /// Full cycles done so far.
  int get cycles => count ~/ cycleSize;

  /// How many counts are done in the cycle that is running now.
  int get countInCycle => count % cycleSize;

  /// How far the cycle that is running has come, from 0 to 1. Full at the end of a
  /// cycle (33 of 33) and empty again with the next count.
  double get cycleProgress => isAtCycleEnd ? 1 : countInCycle / cycleSize;

  /// The count to show inside the cycle: 0..cycleSize (the size itself at its end).
  int get shownInCycle => isAtCycleEnd ? cycleSize : countInCycle;

  /// True when [count] has just closed a cycle (33, 66, ...).
  bool get isAtCycleEnd => count > 0 && count % cycleSize == 0;

  DbTally copyWith({
    int? id,
    String? title,
    int? count,
    int? countReset,
    DateTime? created,
    DateTime? lastUpdate,
    bool? isActivated,
    String? audioFile,
  }) {
    return DbTally(
      id: id ?? this.id,
      title: title ?? this.title,
      count: count ?? this.count,
      countReset: countReset ?? this.countReset,
      created: created ?? this.created,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      isActivated: isActivated ?? this.isActivated,
      audioFile: audioFile ?? this.audioFile,
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
      audioFile,
    ];
  }
}
