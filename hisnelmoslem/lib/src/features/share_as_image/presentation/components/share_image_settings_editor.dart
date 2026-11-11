import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/outlined_surface_card.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/models/share_export_quality.dart';
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
          const SizedBox(height: 20),
          ShareSectionHeader(title: s.imageQuality),
          const ShareQualitySection(),
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

/// The three colors of the image. Each row opens the color picker.
class ShareColorSection extends StatelessWidget {
  const ShareColorSection({super.key});

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
                  ShareColorRow(
                    title: s.titleColor,
                    color: settings.titleTextColor,
                    onPicked: cubit.updateTitleColor,
                  ),
                  const Divider(height: 1),
                  ShareColorRow(
                    title: s.shareImageTextColor,
                    color: settings.additionalTextColor,
                    onPicked: cubit.updateAdditionalTextColor,
                  ),
                  const Divider(height: 1),
                  ShareColorRow(
                    title: s.backgroundColor,
                    color: settings.backgroundColor,
                    onPicked: cubit.updateBackgroundColor,
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

/// One color: its sample, name and hex code. Tapping opens the picker.
class ShareColorRow extends StatelessWidget {
  final String title;
  final Color color;
  final ValueChanged<Color> onPicked;

  const ShareColorRow({
    super.key,
    required this.title,
    required this.color,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsetsDirectional.only(start: 16, end: 12),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(color: theme.colorScheme.outline),
        ),
      ),
      title: Text(title),
      subtitle: Text(color.hexCode, textDirection: TextDirection.ltr),
      trailing: Icon(Icons.colorize_rounded, color: theme.colorScheme.primary),
      onTap: () async {
        final picked = await SelectColorDialog.show(context, title: title, color: color);
        if (picked != null) onPicked(picked);
      },
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

/// How sharp the exported picture is, with the width it gives.
class ShareQualitySection extends StatelessWidget {
  const ShareQualitySection({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final cubit = context.read<ShareImageCubit>();

    return BlocBuilder<ShareImageCubit, ShareImageState>(
      builder: (context, state) {
        if (state is! ShareImageLoadedState) return const SizedBox.shrink();
        final quality = state.shareImageSettings.exportQuality;
        final width = (state.settings.imageSize.width * quality.pixelRatio).round();

        return OutlinedSurfaceCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<ShareExportQuality>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: ShareExportQuality.standard,
                    label: Text(s.shareQualityStandard),
                  ),
                  ButtonSegment(value: ShareExportQuality.high, label: Text(s.shareQualityHigh)),
                  ButtonSegment(value: ShareExportQuality.max, label: Text(s.shareQualityMax)),
                ],
                selected: {quality},
                onSelectionChanged: (value) => cubit.updateExportQuality(value.first),
              ),
              const SizedBox(height: 10),
              Text(
                s.shareImageQualityHint(width),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
