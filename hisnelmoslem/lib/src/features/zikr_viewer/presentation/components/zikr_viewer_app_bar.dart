import 'package:flutter/material.dart';
import 'package:hisnelmoslem/src/features/translations/presentation/components/title_translation_text.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/zikr_viewer_progress_bar.dart';

/// App bar shared by the page and card modes of the zikr viewer: back, the title with its
/// translation and the mode's own [actions]. Progress is the segmented bar under it.
class ZikrViewerAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const double _progressHeight = 22;

  final String title;
  final int titleId;

  final List<Widget> actions;
  final bool showProgress;

  const ZikrViewerAppBar({
    super.key,
    required this.title,
    required this.titleId,
    this.actions = const [],
    this.showProgress = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (showProgress ? _progressHeight : 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: TitleWithTranslation(name: title, titleId: titleId),
      actions: actions,
      bottom: showProgress
          ? const PreferredSize(
              preferredSize: Size.fromHeight(_progressHeight),
              child: Padding(
                padding: EdgeInsetsDirectional.only(start: 16, end: 16, bottom: 10),
                child: ZikrViewerProgressBar(),
              ),
            )
          : null,
    );
  }
}
