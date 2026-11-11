import 'package:flutter_test/flutter_test.dart';
import 'package:hisnelmoslem/src/features/effects_manager/data/models/effect_tier.dart';

void main() {
  bool all(EffectTier _) => true;
  bool only(Set<EffectTier> tiers, EffectTier t) => tiers.contains(t);

  test("a plain tap gives the praise effect", () {
    expect(
      pickEffectTier(zikrCompleted: false, titleCompleted: false, isEnabled: all),
      EffectTier.praise,
    );
  });

  test("finishing a zikr gives the zikr effect instead of the praise one", () {
    expect(
      pickEffectTier(zikrCompleted: true, titleCompleted: false, isEnabled: all),
      EffectTier.zikr,
    );
  });

  test("finishing a title gives the title effect", () {
    expect(
      pickEffectTier(zikrCompleted: true, titleCompleted: true, isEnabled: all),
      EffectTier.title,
    );
  });

  test("a disabled bigger effect falls back to the next enabled one", () {
    bool noTitle(EffectTier t) => t != EffectTier.title;
    expect(
      pickEffectTier(zikrCompleted: true, titleCompleted: true, isEnabled: noTitle),
      EffectTier.zikr,
    );
    expect(
      pickEffectTier(
        zikrCompleted: true,
        titleCompleted: true,
        isEnabled: (t) => only({EffectTier.praise}, t),
      ),
      EffectTier.praise,
    );
  });

  test("an effect of a tier the tap did not reach is never played", () {
    expect(
      pickEffectTier(
        zikrCompleted: false,
        titleCompleted: false,
        isEnabled: (t) => only({EffectTier.zikr, EffectTier.title}, t),
      ),
      isNull,
    );
  });

  test("nothing enabled plays nothing", () {
    expect(
      pickEffectTier(zikrCompleted: true, titleCompleted: true, isEnabled: (_) => false),
      isNull,
    );
  });
}
