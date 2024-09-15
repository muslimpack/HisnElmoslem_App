// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_object.dart';
import 'package:hisnelmoslem/src/core/repos/app_data.dart';
import 'package:hisnelmoslem/src/core/shared/dialogs/commentary_dialog.dart';
import 'package:hisnelmoslem/src/core/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/text_divider.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/screens/share_as_image.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/zikr_content_builder.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/controller/bloc/zikr_page_viewer_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ZikrViewerCardBuilder extends StatelessWidget {
  final DbContent dbContent;

  const ZikrViewerCardBuilder({
    super.key,
    required this.dbContent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TopBar(dbContent: dbContent),
          const Divider(height: 0),
          InkWell(
            onTap: () {
              context.read<ZikrPageViewerBloc>().add(
                    ZikrPageViewerDecreaseActiveZikrEvent(content: dbContent),
                  );
            },
            onLongPress: () {
              context
                  .read<ZikrPageViewerBloc>()
                  .add(ZikrPageViewerCopyActiveZikrEvent(content: dbContent));
            },
            child: Container(
              constraints: const BoxConstraints(minHeight: 200),
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ZikrContentBuilder(
                    dbContent: dbContent,
                    enableDiacritics: AppData.instance.isDiacriticsEnabled,
                    fontSize: AppData.instance.fontSize * 10,
                  ),
                  if (dbContent.fadl.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const TextDivider(),
                    Text(
                      dbContent.fadl,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: AppData.instance.fontSize * 8,
                        height: 2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const Divider(height: 0),
          _BottomBar(dbContent: dbContent),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.dbContent,
  });

  final DbContent dbContent;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () async {
            context
                .read<ZikrPageViewerBloc>()
                .add(ZikrPageViewerResetActiveZikrEvent(content: dbContent));
          },
          icon: const Icon(Icons.repeat),
        ),
        IconButton(
          icon: const Icon(
            Icons.copy,
          ),
          onPressed: () async {
            context
                .read<ZikrPageViewerBloc>()
                .add(ZikrPageViewerCopyActiveZikrEvent(content: dbContent));
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.report,
            color: Colors.orange,
          ),
          onPressed: () {
            context
                .read<ZikrPageViewerBloc>()
                .add(ZikrPageViewerReportActiveZikrEvent(content: dbContent));
          },
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.dbContent,
  });

  final DbContent dbContent;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          splashRadius: 20,
          icon: Icon(MdiIcons.comment),
          onPressed: () {
            showCommentaryDialog(
              context: Get.context!,
              contentId: dbContent.id,
            );
          },
        ),
        IconButton(
          splashRadius: 20,
          icon: Icon(MdiIcons.camera),
          onPressed: () {
            transitionAnimation.circleReval(
              context: Get.context!,
              goToPage: ShareAsImage(
                dbContent: dbContent,
              ),
            );
          },
        ),
        if (!dbContent.favourite)
          IconButton(
            icon: const Icon(
              Icons.favorite_border,
            ),
            onPressed: () {
              context.read<ZikrPageViewerBloc>().add(
                    ZikrPageViewerToggleActiveZikrBookmarkEvent(
                      bookmark: true,
                      content: dbContent,
                    ),
                  );
            },
          )
        else
          IconButton(
            icon: Icon(
              Icons.favorite,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              context.read<ZikrPageViewerBloc>().add(
                    ZikrPageViewerToggleActiveZikrBookmarkEvent(
                      bookmark: false,
                      content: dbContent,
                    ),
                  );
            },
          ),
        IconButton(
          icon: const Icon(
            Icons.share,
          ),
          onPressed: () {
            context
                .read<ZikrPageViewerBloc>()
                .add(ZikrPageViewerShareActiveZikrEvent(content: dbContent));
          },
        ),
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
    );
  }
}
