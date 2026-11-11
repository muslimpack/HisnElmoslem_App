import 'package:flutter_test/flutter_test.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/custom_title_source.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_kind.dart';

void main() {
  test("the kind is read from the viewer title id", () {
    expect(ZikrKind.fromTitleId(0), ZikrKind.hisn);
    expect(ZikrKind.fromTitleId(87), ZikrKind.hisn);
    expect(ZikrKind.fromTitleId(-1), ZikrKind.fakeHadith);
    expect(ZikrKind.fromTitleId(customViewerTitleId(1)), ZikrKind.custom);
    expect(ZikrKind.fromTitleId(customViewerTitleId(41)), ZikrKind.custom);
  });
}
