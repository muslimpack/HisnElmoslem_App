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
  showZikrIndex: true,
  removeDiacritics: false,
  imageWidth: 1080,
  imageQuality: 1,
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

  testWidgets("a very long zikr makes the image taller instead of shrinking the text", (
    tester,
  ) async {
    final long = List.filled(120, "سبحان الله وبحمده سبحان الله العظيم").join(" ");
    await pump(
      tester,
      size: const Size(1080, 1080),
      zikr: _zikr(text: long),
    );

    expect(cardHeight(tester), greaterThan(1080));
    expect(tester.takeException(), isNull);
  });

  testWidgets("the taller the zikr, the taller the image", (tester) async {
    final medium = List.filled(40, "سبحان الله وبحمده").join(" ");
    final long = List.filled(160, "سبحان الله وبحمده").join(" ");

    await pump(
      tester,
      size: const Size(1080, 1080),
      zikr: _zikr(text: medium),
    );
    final mediumHeight = cardHeight(tester);
    await pump(
      tester,
      size: const Size(1080, 1080),
      zikr: _zikr(text: long),
    );

    expect(cardHeight(tester), greaterThan(mediumHeight));
  });

  testWidgets("a long fadl is shown in full and a split zikr still fits", (tester) async {
    final fadl = List.filled(40, "من قالها موقنا بها فمات من يومه دخل الجنة").join(" ");
    await pump(
      tester,
      size: const Size(1080, 1080),
      zikr: _zikr(fadl: fadl),
      splitLength: 3,
    );

    expect(find.textContaining("من قالها موقنا", findRichText: true), findsWidgets);
    expect(cardHeight(tester), greaterThan(1080));
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

  testWidgets("the zikr number is a badge beside the title, not part of the title", (
    tester,
  ) async {
    await pump(tester, size: const Size(1080, 1080), zikr: _zikr());

    expect(find.text("أذكار المساء"), findsOneWidget);
    expect(find.text("4"), findsOneWidget);
    expect(find.textContaining("::"), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets("no number badge when the zikr index is switched off", (tester) async {
    await pump(
      tester,
      size: const Size(1080, 1080),
      zikr: _zikr(),
      settings: _settings.copyWith(showZikrIndex: false),
    );

    expect(find.text("4"), findsNothing);
  });

  testWidgets("a three digit number and a long title still fit", (tester) async {
    await pump(
      tester,
      size: const Size(1080, 1080),
      zikr: _zikr().copyWith(order: 123),
      zikrTitle: const DbTitle(
        id: 1,
        name: "أذكار الاستيقاظ من النوم وما يقال عند الخروج من المنزل",
        freq: "",
        order: 1,
      ),
    );

    expect(find.text("123"), findsOneWidget);
    expect(tester.takeException(), isNull);
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
