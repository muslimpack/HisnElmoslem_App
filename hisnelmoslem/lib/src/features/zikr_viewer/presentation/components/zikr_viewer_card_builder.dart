// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/features/settings/presentation/controller/cubit/settings_cubit.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/zikr_viewer_top_bar.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/zikr_viewer_zikr_body.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/controller/bloc/zikr_viewer_bloc.dart';

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
          ZikrViewerTopBar(dbContent: dbContent),
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
                      ZikrViewerZikrBody(dbContent: dbContent),
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
            Icons.report_outlined,
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
