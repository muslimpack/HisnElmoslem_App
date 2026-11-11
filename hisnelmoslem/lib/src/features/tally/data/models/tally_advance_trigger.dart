/// When a counter hands over to the next one, if auto-advance (circular or shuffle) is on.
enum TallyAdvanceTrigger {
  /// After every single count.
  perCount,

  /// Only when a full cycle (for example 33) is complete.
  perCycle;

  static TallyAdvanceTrigger fromName(String? name) {
    return TallyAdvanceTrigger.values.where((x) => x.name == name).firstOrNull ??
        TallyAdvanceTrigger.perCount;
  }
}
