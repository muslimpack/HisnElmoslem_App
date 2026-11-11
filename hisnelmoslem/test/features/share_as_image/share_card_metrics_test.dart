import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/components/widgets/share_card_metrics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const titleStyle = TextStyle(fontSize: 54, height: 1.4, fontWeight: FontWeight.bold);
  const mainStyle = TextStyle(fontSize: 150, height: 1.45);
  const secondaryStyle = TextStyle(fontSize: 34, height: 1.5);

  ShareCardLayout layout(String text, {double minHeight = 1080, double width = 1080}) {
    return ShareCardMetrics.layout(
      minHeight: minHeight,
      imageWidth: width,
      title: "أذكار الصباح",
      titleStyle: titleStyle,
      mainText: text,
      mainStyle: mainStyle,
      secondaryStyle: secondaryStyle,
      fadl: "من قالها موقنا بها حين يمسي",
      count: 3,
    );
  }

  String words(int repeats) => List.filled(repeats, "سبحان الله وبحمده").join(" ");

  test("a short zikr keeps the requested size and gets large text", () {
    final result = layout(words(1));

    expect(result.height, 1080);
    expect(result.mainFontSize, greaterThanOrEqualTo(ShareCardMetrics.minReadableFontSize));
  });

  test("a medium zikr grows the image and keeps the readable text size", () {
    final result = layout(words(6));

    expect(result.height, greaterThan(1080));
    expect(result.height, lessThanOrEqualTo(1080 * ShareCardMetrics.maxAspectRatio));
    expect(result.mainFontSize, ShareCardMetrics.minReadableFontSize);
  });

  test("the image is never taller than 2:3", () {
    for (final repeats in [1, 5, 10, 20, 50, 200, 1000]) {
      final result = layout(words(repeats));

      expect(
        result.height,
        lessThanOrEqualTo(1080 * ShareCardMetrics.maxAspectRatio),
        reason: "$repeats repeats",
      );
    }
    expect(ShareCardMetrics.maxAspectRatio, 1.5);
  });

  test("past 2:3 the text shrinks, a little more for each longer zikr", () {
    final long = layout(words(20));
    final longer = layout(words(40));
    final longest = layout(words(80));

    expect(long.height, 1080 * 1.5);
    expect(longer.height, 1080 * 1.5);
    expect(long.mainFontSize, lessThan(ShareCardMetrics.minReadableFontSize));
    expect(longer.mainFontSize, lessThan(long.mainFontSize));
    expect(longest.mainFontSize, lessThan(longer.mainFontSize));
  });

  test("the chosen text size really fits: its height is within the room left", () {
    // Measure the way the card draws it and compare with the room the layout left.
    final text = words(80);
    final result = layout(text);
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: mainStyle.copyWith(fontSize: result.mainFontSize),
      ),
      textDirection: TextDirection.rtl,
    )..layout(maxWidth: ShareCardMetrics.contentWidth(1080));

    // Everything else on the card is below ~900 px, so the text has at least this.
    expect(painter.height, lessThanOrEqualTo(result.height - 400));
    // And it is not needlessly small: one step bigger would not fit... within a margin.
    final bigger = TextPainter(
      text: TextSpan(
        text: text,
        style: mainStyle.copyWith(fontSize: result.mainFontSize + 3),
      ),
      textDirection: TextDirection.rtl,
    )..layout(maxWidth: ShareCardMetrics.contentWidth(1080));
    expect(bigger.height, greaterThan(painter.height));
  });

  test("an absurdly long zikr is still shown, at the smallest size", () {
    final result = layout(words(5000));

    expect(result.height, 1080 * 1.5);
    expect(result.mainFontSize, ShareCardMetrics.floorFontSize);
  });

  test("a requested image taller than 2:3 is left alone", () {
    final result = layout(words(1), minHeight: 2000);

    expect(result.height, 2000);
  });

  test("a different image width scales the limit", () {
    final result = layout(words(120), width: 800);

    expect(result.height, 800 * 1.5);
  });
}
