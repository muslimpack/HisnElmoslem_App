import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/font_settings.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/controller/bloc/zikr_viewer_bloc.dart';

class ZikrViewerPageModeBottomBar extends StatelessWidget {
  const ZikrViewerPageModeBottomBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            tooltip: S.of(context).resetZikr,
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.repeat),
            onPressed: () async {
              context
                  .read<ZikrViewerBloc>()
                  .add(const ZikrViewerResetZikrEvent());
            },
          ),
          const VerticalDivider(),
          const Expanded(
            flex: 3,
            child: FontSettingsBar(),
          ),
          const VerticalDivider(),
          IconButton(
            tooltip: S.of(context).report,
            splashRadius: 20,
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.report,
              color: Colors.orange,
            ),
            onPressed: () async {
              context
                  .read<ZikrViewerBloc>()
                  .add(const ZikrViewerReportZikrEvent());
            },
          ),
        ],
      ),
    );
  }
}
