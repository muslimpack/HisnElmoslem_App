import 'package:hisnelmoslem/src/features/tally/data/models/tally.dart';

/// When a counter hands over to the next one, if auto-advance (circular or shuffle) is on. One setting for all counters.
enum TallyAdvanceTrigger {
  /// After every single count.
  perCount,

  /// Only when a full cycle (for example 33) is complete.
  perCycle;

  /// Whether auto-advance should move on after [counted], the counter as it is right
  /// after the count was added.
  bool shouldAdvance(DbTally counted) => switch (this) {
    TallyAdvanceTrigger.perCount => true,
    TallyAdvanceTrigger.perCycle => counted.isAtCycleEnd,
  };

  static TallyAdvanceTrigger fromName(String? name) {
    return TallyAdvanceTrigger.values.where((x) => x.name == name).firstOrNull ??
        TallyAdvanceTrigger.perCount;
  }
}
