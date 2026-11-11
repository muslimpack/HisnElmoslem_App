import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/models/share_export_quality.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/models/share_image_settings.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/services/share_image_export.dart';

void main() {
  group("pixel ratio", () {
    test("follows the chosen quality for a normal card", () {
      const card = Size(1080, 1080);

      expect(ShareImageExport.pixelRatio(ShareExportQuality.standard, card), 1);
      expect(ShareImageExport.pixelRatio(ShareExportQuality.high, card), 1.5);
      // 2 x 1080 = 2160 px, within the limit.
      expect(ShareImageExport.pixelRatio(ShareExportQuality.max, card), 2);
    });

    test("is lowered so a tall card stays within the size limit", () {
      // A long zikr: 1080 x 3000 logical px would be 6000 px tall at 2x.
      const tall = Size(1080, 3000);
      final ratio = ShareImageExport.pixelRatio(ShareExportQuality.max, tall);

      expect(ratio, lessThan(2));
      expect(tall.height * ratio, lessThanOrEqualTo(ShareImageExport.maxSidePixels));
      expect(tall.height * ratio, closeTo(ShareImageExport.maxSidePixels, 1));
    });

    test("an extremely tall card is still exported, only smaller", () {
      final ratio = ShareImageExport.pixelRatio(
        ShareExportQuality.standard,
        const Size(1080, 9000),
      );

      expect(ratio, greaterThan(0));
      expect(9000 * ratio, lessThanOrEqualTo(ShareImageExport.maxSidePixels));
    });

    test("a card that is not measured yet keeps the quality", () {
      expect(ShareImageExport.pixelRatio(ShareExportQuality.high, Size.zero), 1.5);
    });
  });

  group("file names", () {
    final time = DateTime.fromMillisecondsSinceEpoch(1700000000000);

    test("a single image has no page suffix", () {
      expect(
        ShareImageExport.fileName(zikrId: 12, pageIndex: 0, pageCount: 1, time: time),
        "Hisn-12-1700000000000.png",
      );
    });

    test("the pages of a split zikr are numbered", () {
      expect(
        ShareImageExport.fileName(zikrId: 12, pageIndex: 1, pageCount: 3, time: time),
        "Hisn-12_2_of_3-1700000000000.png",
      );
    });

    test("a zikr of a custom title is named Custom", () {
      expect(
        ShareImageExport.fileName(zikrId: -5, pageIndex: 0, pageCount: 1, time: time),
        "Custom-5-1700000000000.png",
      );
    });
  });

  group("saved settings", () {
    test("settings saved before the quality existed open with the default quality", () {
      const old =
          '{"titleTextColor":4278225823,"bodyTextColor":4294965486,"additionalTextColor":4294959801,'
          '"backgroundColor":4279638561,"fontSize":25.0,"showFadl":true,"showSource":true,'
          '"showZikrIndex":true,"removeDiacritics":false,"imageWidth":600,"imageQuality":2.0}';

      final settings = ShareImageSettings.fromJson(old);

      expect(settings.exportQuality, ShareExportQuality.high);
    });

    test("the quality survives saving and loading", () {
      final settings = ShareImageSettings.fromJson(
        const ShareImageSettings(
          titleTextColor: Colors.teal,
          bodyTextColor: Colors.white,
          additionalTextColor: Colors.white,
          backgroundColor: Colors.black,
          fontSize: 25,
          showFadl: true,
          showSource: false,
          removeDiacritics: false,
          exportQuality: ShareExportQuality.max,
        ).toJson(),
      );

      expect(settings.exportQuality, ShareExportQuality.max);
    });

    test("an unknown quality name falls back to high", () {
      expect(ShareExportQuality.fromName("ultra"), ShareExportQuality.high);
      expect(ShareExportQuality.fromName(null), ShareExportQuality.high);
    });
  });
}
