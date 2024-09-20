// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/extensions/extension.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_object.dart';
import 'package:hisnelmoslem/src/core/shared/dialogs/commentary_dialog.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/text_divider.dart';
import 'package:hisnelmoslem/src/features/settings/presentation/controller/cubit/settings_cubit.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/screens/share_as_image_screen.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/zikr_content_builder.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/controller/bloc/zikr_viewer_bloc.dart';
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
              context.read<ZikrViewerBloc>().add(
                    ZikrViewerDecreaseZikrEvent(content: dbContent),
                  );
            },
            onLongPress: () {
              context
                  .read<ZikrViewerBloc>()
                  .add(ZikrViewerCopyZikrEvent(content: dbContent));
            },
            child: BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, state) {
                return Container(
                  constraints: const BoxConstraints(minHeight: 200),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ZikrContentBuilder(
                        dbContent: dbContent,
                        enableDiacritics: state.showDiacritics,
                        fontSize: state.fontSize * 10,
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
                            fontSize: state.fontSize * 8,
                            height: 2,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
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
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          tooltip: S.of(context).resetZikr,
          onPressed: () async {
            context
                .read<ZikrViewerBloc>()
                .add(ZikrViewerResetZikrEvent(content: dbContent));
          },
          icon: const Icon(Icons.repeat),
        ),
        IconButton(
          tooltip: S.of(context).report,
          icon: const Icon(
            Icons.report,
            color: Colors.orange,
          ),
          onPressed: () {
            context
                .read<ZikrViewerBloc>()
                .add(ZikrViewerReportZikrEvent(content: dbContent));
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
          tooltip: S.of(context).commentary,
          icon: Icon(MdiIcons.comment),
          onPressed: () {
            showCommentaryDialog(
              context: context,
              contentId: dbContent.id,
            );
          },
        ),
        IconButton(
          tooltip: S.of(context).shareAsImage,
          icon: Icon(MdiIcons.camera),
          onPressed: () {
            context.push(
              ShareAsImageScreen(
                dbContent: dbContent,
              ),
            );
          },
        ),
        if (!dbContent.favourite)
          IconButton(
            tooltip: S.of(context).bookmark,
            icon: const Icon(
              Icons.favorite_border,
            ),
            onPressed: () {
              context.read<ZikrViewerBloc>().add(
                    ZikrViewerToggleZikrBookmarkEvent(
                      bookmark: true,
                      content: dbContent,
                    ),
                  );
            },
          )
        else
          IconButton(
            tooltip: S.of(context).bookmark,
            icon: Icon(
              Icons.favorite,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              context.read<ZikrViewerBloc>().add(
                    ZikrViewerToggleZikrBookmarkEvent(
                      bookmark: false,
                      content: dbContent,
                    ),
                  );
            },
          ),
        IconButton(
          tooltip: S.of(context).share,
          icon: const Icon(
            Icons.share,
          ),
          onPressed: () {
            context
                .read<ZikrViewerBloc>()
                .add(ZikrViewerShareZikrEvent(content: dbContent));
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
