import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/models/share_color_preset.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/models/share_image_settings.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/controller/cubit/share_image_cubit.dart';

/// Localized name of a preset.
extension SharePresetLabel on SharePresetId {
  String label(BuildContext context) {
    final s = S.of(context);
    return switch (this) {
      SharePresetId.classicNight => s.presetClassicNight,
      SharePresetId.emeraldNight => s.presetEmeraldNight,
      SharePresetId.midnightGold => s.presetMidnightGold,
      SharePresetId.deepOcean => s.presetDeepOcean,
      SharePresetId.royalPurple => s.presetRoyalPurple,
      SharePresetId.charcoalCoral => s.presetCharcoalCoral,
      SharePresetId.parchment => s.presetParchment,
      SharePresetId.mintGarden => s.presetMintGarden,
      SharePresetId.cleanWhite => s.presetCleanWhite,
      SharePresetId.roseDawn => s.presetRoseDawn,
      SharePresetId.skyMorning => s.presetSkyMorning,
    };
  }
}

/// Ready-made colors, a dark row and a light row. Tapping one sets the background, the
/// title and the text colors together.
class ShareColorPresetsSection extends StatelessWidget {
  const ShareColorPresetsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocBuilder<ShareImageCubit, ShareImageState>(
      builder: (context, state) {
        if (state is! ShareImageLoadedState) return const SizedBox.shrink();
        final settings = state.shareImageSettings;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SharePresetRow(
              title: s.shareImagePresetDark,
              icon: Icons.dark_mode_rounded,
              presets: [
                for (final p in kShareColorPresets)
                  if (p.isDark) p,
              ],
              settings: settings,
            ),
            const SizedBox(height: 12),
            SharePresetRow(
              title: s.shareImagePresetLight,
              icon: Icons.light_mode_rounded,
              presets: [
                for (final p in kShareColorPresets)
                  if (!p.isDark) p,
              ],
              settings: settings,
            ),
          ],
        );
      },
    );
  }
}

class SharePresetRow extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<ShareColorPreset> presets;
  final ShareImageSettings settings;

  const SharePresetRow({
    super.key,
    required this.title,
    required this.icon,
    required this.presets,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: theme.hintColor),
            const SizedBox(width: 6),
            Text(title, style: theme.textTheme.labelLarge?.copyWith(color: theme.hintColor)),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 118,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: presets.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final preset = presets[index];
              return SharePresetTile(
                preset: preset,
                selected: preset.matches(
                  background: settings.backgroundColor,
                  title: settings.titleTextColor,
                  text: settings.additionalTextColor,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// A miniature of the card in the preset's colors, with its name below.
class SharePresetTile extends StatelessWidget {
  final ShareColorPreset preset;
  final bool selected;

  const SharePresetTile({super.key, required this.preset, required this.selected});

  static const double _width = 116;
  static const double _height = 84;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = preset.id.label(context);

    return Semantics(
      button: true,
      selected: selected,
      label: name,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.read<ShareImageCubit>().applyColorPreset(preset),
        child: SizedBox(
          width: _width,
          child: Column(
            children: [
              Container(
                width: _width,
                height: _height,
                decoration: BoxDecoration(
                  color: preset.background,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                    width: selected ? 3 : 1,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "أذكار",
                            style: TextStyle(
                              color: preset.title,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 3),
                            width: 30,
                            height: 2,
                            color: preset.title.withValues(alpha: .7),
                          ),
                          Text(
                            "سبحان الله",
                            style: TextStyle(color: preset.text, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    if (selected)
                      PositionedDirectional(
                        top: 6,
                        end: 6,
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: theme.colorScheme.primary,
                          child: Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
