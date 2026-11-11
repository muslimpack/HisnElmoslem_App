import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/components/share_image_settings_editor.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/controller/cubit/share_image_cubit.dart';

/// Bottom area of the screen: Share is the main action; customizing and saving are
/// secondary.
class ShareImageActionBar extends StatelessWidget {
  const ShareImageActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final cubit = context.read<ShareImageCubit>();

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      elevation: 8,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // The context of the button, so the share sheet can anchor to it.
              Builder(
                builder: (context) => FilledButton.icon(
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
                  onPressed: () => cubit.shareImage(context),
                  icon: const Icon(Icons.share_rounded),
                  label: Text(s.share),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                      onPressed: () => ShareImageSettingsEditor.show(context),
                      icon: const Icon(Icons.tune_rounded),
                      label: Text(s.shareImageCustomize),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Tooltip(
                      message: s.saveToGallery,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: cubit.saveToGallery,
                        icon: const Icon(Icons.download_rounded),
                        label: Text(s.save),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
