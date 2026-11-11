import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_color.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/outlined_surface_card.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/components/share_color_presets_section.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/components/widgets/select_color_dialog.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/controller/cubit/share_image_cubit.dart';

/// Bottom sheet to change the colors and what the shared image shows.
class ShareImageSettingsEditor extends StatelessWidget {
  const ShareImageSettingsEditor({super.key});

  static Future<void> show(BuildContext context) {
    // The sheet is a separate route and does not see the screen's cubit.
    final cubit = context.read<ShareImageCubit>();

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const SafeArea(top: false, child: ShareImageSettingsEditor()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(s.shareImageCustomize, style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          ShareSectionHeader(title: s.shareImagePresets),
          const ShareColorPresetsSection(),
          const SizedBox(height: 12),
          ShareSectionHeader(
            title: s.shareImageColors,
            action: TextButton.icon(
              onPressed: () => context.read<ShareImageCubit>().resetColors(),
              icon: const Icon(Icons.restart_alt_rounded, size: 20),
              label: Text(s.reset),
            ),
          ),
          const ShareColorSection(),
          const SizedBox(height: 20),
          ShareSectionHeader(title: s.shareImageContent),
          const ShareContentSection(),
        ],
      ),
    );
  }
}

class ShareSectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;

  const ShareSectionHeader({super.key, required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

enum ShareColorTarget { title, text, background }

/// Pick what to color, then a color from the palette (or a custom one).
class ShareColorSection extends StatefulWidget {
  const ShareColorSection({super.key});

  @override
  State<ShareColorSection> createState() => _ShareColorSectionState();
}

class _ShareColorSectionState extends State<ShareColorSection> {
  ShareColorTarget _target = ShareColorTarget.title;

  void _apply(ShareImageCubit cubit, Color color) {
    switch (_target) {
      case ShareColorTarget.title:
        cubit.updateTitleColor(color);
      case ShareColorTarget.text:
        cubit.updateAdditionalTextColor(color);
      case ShareColorTarget.background:
        cubit.updateBackgroundColor(color);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final cubit = context.read<ShareImageCubit>();

    return BlocBuilder<ShareImageCubit, ShareImageState>(
      builder: (context, state) {
        if (state is! ShareImageLoadedState) return const SizedBox.shrink();
        final settings = state.shareImageSettings;

        final colors = {
          ShareColorTarget.title: (s.titleColor, settings.titleTextColor),
          ShareColorTarget.text: (s.shareImageTextColor, settings.additionalTextColor),
          ShareColorTarget.background: (s.backgroundColor, settings.backgroundColor),
        };
        final current = colors[_target]!.$2;

        return OutlinedSurfaceCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                label: s.shareImageColorTarget,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final entry in colors.entries)
                      ChoiceChip(
                        avatar: ColorDot(color: entry.value.$2, size: 20),
                        showCheckmark: false,
                        label: Text(entry.value.$1),
                        selected: _target == entry.key,
                        onSelected: (_) => setState(() => _target = entry.key),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final color in kShareImageColorsList)
                    ColorDot(
                      color: color,
                      selected: color.toARGB32() == current.toARGB32(),
                      onTap: () => _apply(cubit, color),
                    ),
                  CustomColorButton(
                    onTap: () async {
                      final picked = await SelectColorDialog.show(
                        context,
                        colorHistory: kShareImageColorsList,
                        color: current,
                      );
                      if (picked != null) _apply(cubit, picked);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A round color sample; with [onTap] it is a button and shows a check when [selected].
class ColorDot extends StatelessWidget {
  final Color color;
  final double size;
  final bool selected;
  final VoidCallback? onTap;

  const ColorDot({
    super.key,
    required this.color,
    this.size = 44,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: onTap != null,
      selected: selected,
      child: InkResponse(
        onTap: onTap,
        radius: size * .7,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(
              color: selected ? theme.colorScheme.primary : theme.colorScheme.outline,
              width: selected ? 3 : 1,
            ),
          ),
          child: selected
              ? Icon(Icons.check_rounded, size: size * .5, color: color.getContrastColor)
              : null,
        ),
      ),
    );
  }
}

/// Opens the full color picker.
class CustomColorButton extends StatelessWidget {
  final VoidCallback onTap;
  const CustomColorButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: S.of(context).selectColor,
      child: InkResponse(
        onTap: onTap,
        radius: 30,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: theme.colorScheme.outline),
            gradient: const SweepGradient(
              colors: [
                Colors.red,
                Colors.yellow,
                Colors.green,
                Colors.cyan,
                Colors.blue,
                Colors.purple,
                Colors.red,
              ],
            ),
          ),
          child: const Icon(Icons.colorize_rounded, size: 20, color: Colors.white),
        ),
      ),
    );
  }
}

/// What the image shows: the diacritics, the zikr number, fadl and source.
class ShareContentSection extends StatelessWidget {
  const ShareContentSection({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final cubit = context.read<ShareImageCubit>();

    return BlocBuilder<ShareImageCubit, ShareImageState>(
      builder: (context, state) {
        if (state is! ShareImageLoadedState) return const SizedBox.shrink();
        final settings = state.shareImageSettings;

        return OutlinedSurfaceCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            // The rows paint their ink on the nearest Material; the card's colored box
            // would hide it.
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(s.showDiacritics),
                    value: !settings.removeDiacritics,
                    onChanged: (_) => cubit.toggleRemoveDiacritics(),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(s.showZikrIndex),
                    value: settings.showZikrIndex,
                    onChanged: (value) => cubit.updateShowZikrIndex(value: value),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(s.showFadl),
                    value: settings.showFadl,
                    onChanged: (value) => cubit.uodateShowFadl(value: value),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(s.showSourceOfZikr),
                    value: settings.showSource,
                    onChanged: (value) => cubit.updateShowSource(value: value),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
