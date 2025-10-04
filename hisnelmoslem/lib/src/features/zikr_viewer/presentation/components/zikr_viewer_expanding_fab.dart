// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_object.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/font_settings.dart';
import 'package:hisnelmoslem/src/features/bookmark/presentation/components/zikr_toggle_favorite_icon_button.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/side_menu/toggle_brightness_btn.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/commentary_dialog.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/controller/bloc/zikr_viewer_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ZikrViewerExpandingFab extends StatelessWidget {
  final DbContent dbContent;
  const ZikrViewerExpandingFab({super.key, required this.dbContent});

  @override
  Widget build(BuildContext context) {
    return ExpandableFab(
      fanAngle: 180,
      pos: ExpandableFabPos.center,
      openButtonBuilder: RotateFloatingActionButtonBuilder(
        heroTag: 'open',
        child: Text(
          dbContent.count.toString().toArabicNumber(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        shape: const CircleBorder(),
      ),
      closeButtonBuilder: DefaultFloatingActionButtonBuilder(
        heroTag: 'close',
        child: const Icon(Icons.close),
        fabSize: ExpandableFabSize.small,
        shape: const CircleBorder(),
      ),
      children: [
        FloatingActionButton.small(
          heroTag: 'report',
          tooltip: S.of(context).report,
          backgroundColor: Colors.orange.withAlpha(200),
          child: const Icon(Icons.report_outlined),
          onPressed: () {
            context.read<ZikrViewerBloc>().add(ZikrViewerReportZikrEvent(content: dbContent));
          },
        ),
        FloatingActionButton.small(
          heroTag: 'brightness',
          child: const ToggleBrightnessButton(),
          onPressed: () {},
        ),
        FloatingActionButton.small(
          heroTag: 'font',
          child: const FontSettingsIconButton(),
          onPressed: () {},
        ),
        FloatingActionButton.small(
          heroTag: 'reset',
          tooltip: S.of(context).resetZikr,
          child: const Icon(Icons.repeat_rounded),
          onPressed: () {
            context.read<ZikrViewerBloc>().add(ZikrViewerResetZikrEvent(content: dbContent));
          },
        ),
        FloatingActionButton.small(
          heroTag: 'commentary',
          tooltip: S.of(context).commentary,
          child: Icon(MdiIcons.comment),
          onPressed: () {
            showCommentaryDialog(context: context, contentId: dbContent.id);
          },
        ),
        FloatingActionButton.small(
          heroTag: 'bookmark',
          child: ZikrToggleFavoriteIconButton(dbContent: dbContent),
          onPressed: () {
            showCommentaryDialog(context: context, contentId: dbContent.id);
          },
        ),
        FloatingActionButton.small(
          heroTag: 'share',
          tooltip: S.of(context).share,
          child: const Icon(Icons.share),
          onPressed: () {
            context.read<ZikrViewerBloc>().add(ZikrViewerShareZikrEvent(content: dbContent));
          },
        ),
      ],
    );
  }
}
