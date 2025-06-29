// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/settings/presentation/controller/cubit/settings_cubit.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/commentary_dialog.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/zikr_viewer_zikr_body.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/controller/bloc/zikr_viewer_bloc.dart';

class ZikrViewerCardBuilder extends StatelessWidget {
  final DbContent dbContent;
  const ZikrViewerCardBuilder({super.key, required this.dbContent});

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        PinnedHeaderSliver(child: _PinnedCardHeader(dbContent)),
        SliverToBoxAdapter(child: _ZikrCard(dbContent: dbContent)),
      ],
    );
  }
}

class _PinnedCardHeader extends StatelessWidget {
  const _PinnedCardHeader(this.dbContent);
  final DbContent dbContent;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TextButton(
            onPressed: () {
              context.read<ZikrViewerBloc>().add(
                ZikrViewerDecreaseZikrEvent(content: dbContent),
              );
            },
            child: Text(dbContent.count.toString()),
          ),
          IconButton(
            tooltip: S.of(context).resetZikr,
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.repeat),
            onPressed: () {
              context.read<ZikrViewerBloc>().add(
                ZikrViewerResetZikrEvent(content: dbContent),
              );
            },
          ),
          // smallSpacer,
          IconButton(
            tooltip: S.of(context).commentary,
            icon: const Icon(Icons.description_outlined),
            onPressed: () {
              showCommentaryDialog(context: context, contentId: dbContent.id);
            },
          ),
          if (!dbContent.favourite)
            IconButton(
              icon: const Icon(Icons.favorite_border),
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
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(
                      Icons.report_outlined,
                      color: Colors.orange,
                    ),
                    title: Text(S.of(context).report),
                  ),
                  onTap: () {
                    context.read<ZikrViewerBloc>().add(
                      ZikrViewerReportZikrEvent(content: dbContent),
                    );
                  },
                ),
                PopupMenuItem(
                  onTap: () {
                    context.read<ZikrViewerBloc>().add(
                      ZikrViewerShareZikrEvent(content: dbContent),
                    );
                  },
                  child: ListTile(
                    title: Text(S.of(context).share),
                    leading: const Icon(Icons.share),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }
}

class _ZikrCard extends StatelessWidget {
  const _ZikrCard({required this.dbContent});
  final DbContent dbContent;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            context.read<ZikrViewerBloc>().add(
              ZikrViewerDecreaseZikrEvent(content: dbContent),
            );
          },
          onLongPress: () {
            context.read<ZikrViewerBloc>().add(
              ZikrViewerCopyZikrEvent(content: dbContent),
            );
          },
          child: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              return Container(
                constraints: const BoxConstraints(minHeight: 200),
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [ZikrViewerZikrBody(dbContent: dbContent)],
                ),
              );
            },
          ),
        ),
        const Divider(),
      ],
    );
  }
}
