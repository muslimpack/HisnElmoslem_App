import 'package:flutter_test/flutter_test.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/models/share_color_preset.dart';

void main() {
  test("there are both dark and light presets, each with its own name", () {
    expect(kShareColorPresets.where((p) => p.isDark).length, greaterThanOrEqualTo(4));
    expect(kShareColorPresets.where((p) => !p.isDark).length, greaterThanOrEqualTo(4));
    expect(kShareColorPresets.map((p) => p.id).toSet().length, kShareColorPresets.length);
    expect(kShareColorPresets.length, SharePresetId.values.length);
  });

  for (final preset in kShareColorPresets) {
    test("${preset.id.name} is readable", () {
      // The zikr text must stand out from the background; the title/accent color is
      // large and bold, so the lower bar for large text applies.
      expect(
        ShareColorPreset.contrast(preset.text, preset.background),
        greaterThanOrEqualTo(7),
        reason: "text on background",
      );
      expect(
        ShareColorPreset.contrast(preset.title, preset.background),
        greaterThanOrEqualTo(3),
        reason: "title on background",
      );
    });
  }
}
