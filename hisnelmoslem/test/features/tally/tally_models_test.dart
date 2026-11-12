import 'package:flutter_test/flutter_test.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally_session_limit.dart';

import 'tally_test_support.dart';

void main() {
  group('TallySessionLimit', () {
    test('endless never ends', () {
      expect(
        const TallySessionLimit.endless().isReached(
          counted: 100000,
          elapsed: const Duration(days: 1),
        ),
        isFalse,
      );
    });

    test('minutes end by time only', () {
      const limit = TallySessionLimit.minutes(10);
      expect(
        limit.isReached(counted: 999, elapsed: const Duration(minutes: 9, seconds: 59)),
        isFalse,
      );
      expect(limit.isReached(counted: 0, elapsed: const Duration(minutes: 10)), isTrue);
    });

    test('count ends by number of counts only', () {
      const limit = TallySessionLimit.count(33);
      expect(limit.isReached(counted: 32, elapsed: const Duration(days: 1)), isFalse);
      expect(limit.isReached(counted: 33, elapsed: Duration.zero), isTrue);
    });

    test('reads back what was saved, and falls back to endless', () {
      expect(
        TallySessionLimit.fromStorage('minutes', 15),
        const TallySessionLimit.minutes(15),
      );
      expect(TallySessionLimit.fromStorage(null, null), const TallySessionLimit.endless());
      expect(TallySessionLimit.fromStorage('nonsense', 5), const TallySessionLimit.endless());
      expect(
        TallySessionLimit.fromStorage('count', 0),
        const TallySessionLimit.count(1),
        reason: 'a limit of zero would end the session before it starts',
      );
    });
  });

  group('DbTally.cycleProgress', () {
    test('fills during the cycle, is full at its end and empty with the next count', () {
      expect(makeTally('a').cycleProgress, 0);
      expect(makeTally('a', count: 11).cycleProgress, closeTo(1 / 3, 0.001));
      expect(makeTally('a', count: 33).cycleProgress, 1);
      expect(makeTally('a', count: 34).cycleProgress, closeTo(1 / 33, 0.001));
      expect(makeTally('a', count: 66).cycleProgress, 1);
    });
  });
}
