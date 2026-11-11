import 'package:equatable/equatable.dart';

enum TallySessionLimitType { endless, minutes, count }

/// When a playback session of the tally stops by itself: never, after some minutes
/// of playing, or after a number of counts.
class TallySessionLimit extends Equatable {
  final TallySessionLimitType type;

  /// Minutes or counts; ignored when [type] is [TallySessionLimitType.endless].
  final int value;

  const TallySessionLimit(this.type, [this.value = 0]);

  const TallySessionLimit.endless() : this(TallySessionLimitType.endless);
  const TallySessionLimit.minutes(int minutes) : this(TallySessionLimitType.minutes, minutes);
  const TallySessionLimit.count(int count) : this(TallySessionLimitType.count, count);

  static const List<int> minutePresets = [5, 10, 15, 30, 60];
  static const List<int> countPresets = [33, 99, 100, 500, 1000];

  /// Largest values the user can type: a day of playing, a hundred thousand counts.
  static const int maxMinutes = 24 * 60;
  static const int maxCount = 100000;

  /// The limit of [type] for what the user typed, or null when it is not a whole
  /// number between 1 and the largest value.
  static TallySessionLimit? tryParse(TallySessionLimitType type, String text) {
    final value = int.tryParse(text.trim());
    if (value == null || value < 1) return null;
    return switch (type) {
      TallySessionLimitType.endless => const TallySessionLimit.endless(),
      TallySessionLimitType.minutes => value > maxMinutes ? null : TallySessionLimit.minutes(value),
      TallySessionLimitType.count => value > maxCount ? null : TallySessionLimit.count(value),
    };
  }

  bool get isEndless => type == TallySessionLimitType.endless;

  /// True when a session that has counted [counted] times and played for [elapsed]
  /// has reached this limit.
  bool isReached({required int counted, required Duration elapsed}) {
    return switch (type) {
      TallySessionLimitType.endless => false,
      TallySessionLimitType.minutes => elapsed >= Duration(minutes: value),
      TallySessionLimitType.count => counted >= value,
    };
  }

  factory TallySessionLimit.fromStorage(String? typeName, int? value) {
    final type =
        TallySessionLimitType.values.where((x) => x.name == typeName).firstOrNull ??
        TallySessionLimitType.endless;
    final safe = (value ?? 0) < 1 ? 1 : value!;
    return type == TallySessionLimitType.endless
        ? const TallySessionLimit.endless()
        : TallySessionLimit(type, safe);
  }

  @override
  List<Object> get props => [type, value];
}
