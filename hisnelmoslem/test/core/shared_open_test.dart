import 'package:flutter_test/flutter_test.dart';
import 'package:hisnelmoslem/src/core/utils/shared_open.dart';

void main() {
  test('callers that arrive while it is opening share one run', () async {
    var runs = 0;
    final shared = SharedOpen<int>();

    Future<int> open() async {
      runs++;
      await Future<void>.delayed(const Duration(milliseconds: 20));
      return 7;
    }

    final results = await Future.wait([for (var i = 0; i < 8; i++) shared.run(open)]);

    expect(runs, 1);
    expect(results, everyElement(7));
  });

  test('opens again after it finished, so a closed database can be reopened', () async {
    var runs = 0;
    final shared = SharedOpen<int>();
    Future<int> open() async => ++runs;

    expect(await shared.run(open), 1);
    expect(await shared.run(open), 2);
  });

  test('a failure is not remembered', () async {
    var runs = 0;
    final shared = SharedOpen<int>();
    Future<int> open() async {
      runs++;
      if (runs == 1) throw StateError('first try fails');
      return runs;
    }

    await expectLater(shared.run(open), throwsStateError);
    expect(await shared.run(open), 2);
  });
}
