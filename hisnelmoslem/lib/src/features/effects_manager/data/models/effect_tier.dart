/// How significant a tap is. A bigger tier replaces the smaller ones, because only
/// one sound and one vibration can reasonably play for a single tap.
enum EffectTier { praise, zikr, title }

/// The effect to play for one tap: the most significant tier reached by the tap
/// that the user has enabled, or null when none is enabled.
///
/// A tap that finishes the whole title also finishes its zikr, and every tap is a
/// praise; if the user turned the title effect off, the zikr effect plays instead,
/// and so on down to the praise effect.
EffectTier? pickEffectTier({
  required bool zikrCompleted,
  required bool titleCompleted,
  required bool Function(EffectTier tier) isEnabled,
}) {
  final reached = [
    if (titleCompleted) EffectTier.title,
    if (zikrCompleted || titleCompleted) EffectTier.zikr,
    EffectTier.praise,
  ];
  for (final tier in reached) {
    if (isEnabled(tier)) return tier;
  }
  return null;
}
