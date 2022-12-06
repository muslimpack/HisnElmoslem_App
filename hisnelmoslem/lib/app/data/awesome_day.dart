class AwesomeDay {
  /// Constructs an instance of [Day].
  const AwesomeDay(this.value);

  /// Monday.
  static const AwesomeDay monday = AwesomeDay(1);

  /// Tuesday.
  static const AwesomeDay tuesday = AwesomeDay(2);

  /// Wednesday.
  static const AwesomeDay wednesday = AwesomeDay(3);

  /// Thursday.
  static const AwesomeDay thursday = AwesomeDay(4);

  /// Friday.
  static const AwesomeDay friday = AwesomeDay(5);

  /// Saturday.
  static const AwesomeDay saturday = AwesomeDay(6);

  /// Sunday.
  static const AwesomeDay sunday = AwesomeDay(7);

  /// All the possible values for the [Day] enumeration.
  static List<AwesomeDay> get values => <AwesomeDay>[
        monday,
        tuesday,
        wednesday,
        thursday,
        friday,
        saturday,
        sunday
      ];

  /// The integer representation.
  final int value;
}
