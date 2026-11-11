import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/models/share_image_settings.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/models/shareable_image_card_settings.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/components/widgets/shareable_image_card.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

const _settings = ShareImageSettings(
  titleTextColor: Color(0xFF26A69A),
  bodyTextColor: Colors.white,
  additionalTextColor: Color(0xFFFFE0B2),
  backgroundColor: Color(0xFF121820),
  fontSize: 20,
  showFadl: true,
  showSource: true,
  removeDiacritics: false,
);

DbContent _zikr({String? text, String fadl = "من قالها موقنا بها حين يمسي", int count = 3}) =>
    DbContent(
      id: 1,
      content: text ?? "اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ",
      titleId: 1,
      order: 4,
      count: count,
      fadl: fadl,
      source: "أخرجه البخاري، 7/ 150، برقم 6306",
      search: "",
      hokm: "",
      audio: "",
      hasAudio: false,
    );

void main() {
  const title = DbTitle(id: 1, name: "أذكار المساء", freq: "", order: 1);

  Future<void> pump(
    WidgetTester tester, {
    required Size size,
    required DbContent zikr,
    DbTitle zikrTitle = title,
    ShareImageSettings settings = _settings,
    int splitLength = 0,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        // As in the app, the card may be taller than the screen.
        home: Scaffold(
          body: SingleChildScrollView(
            child: ShareableImageCard(
              zikrTitle: zikrTitle,
              zikr: zikr,
              settings: ShareableImageCardSettings(
                imageSize: size,
                wordsCountPerSize: 1500,
                mainFontFamily: "kitab",
                secondaryFontFamily: "kitab",
              ),
              shareImageSettings: settings,
              splittedLength: splitLength,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  for (final size in const [Size(1080, 1080), Size(1080, 1350), Size(1080, 1920)]) {
    testWidgets("lays out with every detail at ${size.width.toInt()}x${size.height.toInt()}", (
      tester,
    ) async {
      await pump(tester, size: size, zikr: _zikr());

      expect(find.text("تطبيق حصن المسلم"), findsOneWidget);
      expect(find.textContaining("عدد المرات: 3"), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  double cardHeight(WidgetTester tester) => tester.getSize(find.byType(ShareableImageCard)).height;

  testWidgets("a short zikr keeps the requested image size", (tester) async {
    await pump(tester, size: const Size(1080, 1080), zikr: _zikr());

    expect(cardHeight(tester), 1080);
  });

  /// The zikr text must not run into the title above it or the details below it.
  void expectTextClear(WidgetTester tester, String text) {
    final textRect = tester.getRect(find.text(text));
    final footer = tester.getRect(find.byType(ShareCardFooter));
    final title = tester.getRect(find.byType(ShareCardTitle));

    expect(textRect.top, greaterThanOrEqualTo(title.bottom), reason: "under the title");
    expect(textRect.bottom, lessThanOrEqualTo(footer.top), reason: "above the footer");
  }

  testWidgets("a medium zikr grows the image, but stays within 2:3", (tester) async {
    final medium = List.filled(6, "سبحان الله وبحمده").join(" ");
    await pump(
      tester,
      size: const Size(1080, 1080),
      zikr: _zikr(text: medium),
    );

    expect(cardHeight(tester), greaterThan(1080));
    expect(cardHeight(tester), lessThanOrEqualTo(1080 * 1.5));
    expectTextClear(tester, medium);
    expect(tester.takeException(), isNull);
  });

  testWidgets("a very long zikr stops at 2:3 and its whole text is still shown", (tester) async {
    final long = List.filled(60, "سبحان الله وبحمده سبحان الله العظيم").join(" ");
    await pump(
      tester,
      size: const Size(1080, 1080),
      zikr: _zikr(text: long),
    );

    expect(cardHeight(tester), 1080 * 1.5);
    expectTextClear(tester, long);
    // Not cut: no line limit and no ellipsis.
    final text = tester.widget<Text>(find.text(long));
    expect(text.maxLines, isNull);
    expect(text.overflow, isNot(TextOverflow.ellipsis));
    expect(tester.takeException(), isNull);
  });

  testWidgets("a longer zikr gets smaller text, not a taller image, once at 2:3", (
    tester,
  ) async {
    final long = List.filled(20, "سبحان الله وبحمده سبحان الله العظيم").join(" ");
    final longer = List.filled(40, "سبحان الله وبحمده سبحان الله العظيم").join(" ");

    await pump(
      tester,
      size: const Size(1080, 1080),
      zikr: _zikr(text: long),
    );
    final fontOfLong = tester.widget<Text>(find.text(long)).style!.fontSize!;
    await pump(
      tester,
      size: const Size(1080, 1080),
      zikr: _zikr(text: longer),
    );
    final fontOfLonger = tester.widget<Text>(find.text(longer)).style!.fontSize!;

    expect(cardHeight(tester), 1080 * 1.5);
    expect(fontOfLonger, lessThan(fontOfLong));
    expectTextClear(tester, longer);
  });

  testWidgets("a long fadl and a split zikr never pass 2:3", (tester) async {
    final fadl = List.filled(40, "من قالها موقنا بها فمات من يومه دخل الجنة").join(" ");
    await pump(
      tester,
      size: const Size(1080, 1080),
      zikr: _zikr(fadl: fadl),
      splitLength: 3,
    );

    expect(find.textContaining("من قالها موقنا", findRichText: true), findsWidgets);
    expect(cardHeight(tester), lessThanOrEqualTo(1080 * 1.5));
    expect(tester.takeException(), isNull);
  });

  testWidgets("only the main text when fadl, source and count are off", (tester) async {
    await pump(
      tester,
      size: const Size(1080, 1080),
      zikr: _zikr(count: 1),
      settings: _settings.copyWith(showFadl: false, showSource: false),
    );

    expect(find.textContaining("المصدر"), findsNothing);
    expect(find.textContaining("عدد المرات"), findsNothing);
    expect(find.textContaining("الفضل"), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets("the zikr number is not on the image", (tester) async {
    // The zikr is number 4 in its title; nothing on the card should say so.
    await pump(tester, size: const Size(1080, 1080), zikr: _zikr());

    expect(find.text("4"), findsNothing);
    expect(find.textContaining("::"), findsNothing);
    expect(find.text("أذكار المساء"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets("the title is centered, with nothing beside it", (tester) async {
    await pump(tester, size: const Size(1080, 1080), zikr: _zikr());

    final card = tester.getRect(find.byType(ShareableImageCard));
    final title = tester.getRect(find.text("أذكار المساء"));
    expect(title.center.dx, closeTo(card.center.dx, 1));
  });

  testWidgets("a custom zikr shows its fadl without the label", (tester) async {
    await pump(
      tester,
      size: const Size(1080, 1080),
      zikr: _zikr(),
      zikrTitle: const DbTitle(id: -2, name: "أذكاري", freq: "", order: 0),
    );

    expect(find.textContaining("الفضل: "), findsNothing);
    expect(find.textContaining("من قالها موقنا"), findsOneWidget);
  });
}
