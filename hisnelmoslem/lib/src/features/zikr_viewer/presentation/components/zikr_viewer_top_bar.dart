import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_object.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_platform.dart';
import 'package:hisnelmoslem/src/core/shared/dialogs/commentary_dialog.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/side_menu/toggle_brightness_btn.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/controller/bloc/zikr_viewer_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ZikrViewerTopBar extends StatelessWidget {
  final DbContent dbContent;
  const ZikrViewerTopBar({
    super.key,
    required this.dbContent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              tooltip: S.of(context).commentary,
              icon: Icon(MdiIcons.comment),
              onPressed: () {
                showCommentaryDialog(
                  context: context,
                  contentId: dbContent.id,
                );
              },
            ),
            if (!dbContent.favourite)
              IconButton(
                tooltip: S.of(context).bookmark,
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.favorite_border,
                ),
                onPressed: () {
                  context.read<ZikrViewerBloc>().add(
                        ZikrViewerToggleZikrBookmarkEvent(
                          content: dbContent,
                          bookmark: true,
                        ),
                      );
                },
              )
            else
              IconButton(
                tooltip: S.of(context).bookmark,
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.favorite,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  context.read<ZikrViewerBloc>().add(
                        ZikrViewerToggleZikrBookmarkEvent(
                          content: dbContent,
                          bookmark: false,
                        ),
                      );
                },
              ),
            IconButton(
              tooltip: S.of(context).share,
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.share),
              onPressed: () async {
                context
                    .read<ZikrViewerBloc>()
                    .add(ZikrViewerShareZikrEvent(content: dbContent));
              },
            ),
            if (!PlatformExtension.isDesktop) const ToggleBrightnessButton(),
            Center(
              child: Text(
                dbContent.count.toString().toArabicNumber(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
