import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/controller/bloc/zikr_page_viewer_bloc.dart';

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
          Expanded(
            child: IconButton(
              splashRadius: 20,
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.copy),
              onPressed: () async {
                context
                    .read<ZikrPageViewerBloc>()
                    .add(ZikrPageViewerCopyActiveZikrEvent());
              },
            ),
          ),

          ///TODO FontSettingsToolbox
          // Expanded(
          //   flex: 3,
          //   child: FontSettingsToolbox(
          //     controllerToUpdate: controller,
          //   ),
          // ),
          Expanded(
            child: IconButton(
              splashRadius: 20,
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.report,
                color: Colors.orange,
              ),
              onPressed: () async {
                context
                    .read<ZikrPageViewerBloc>()
                    .add(ZikrPageViewerReportActiveZikrEvent());
              },
            ),
          ),
        ],
      ),
    );
  }
}
