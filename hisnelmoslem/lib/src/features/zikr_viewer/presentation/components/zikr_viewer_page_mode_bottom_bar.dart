import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/font_settings.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/navigation_slider.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/controller/bloc/zikr_viewer_bloc.dart';

class ZikrViewerPageModeBottomBar extends StatelessWidget {
  final DbContent dbContent;
  const ZikrViewerPageModeBottomBar({super.key, required this.dbContent});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
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
              const FontSettingsIconButton(),
              IconButton(
                tooltip: S.of(context).report,
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.report_outlined, color: Colors.orange),
                onPressed: () {
                  context.read<ZikrViewerBloc>().add(
                    ZikrViewerReportZikrEvent(content: dbContent),
                  );
                },
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: NavigationSlider(),
          ),
        ],
      ),
    );
  }
}
