import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_object.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_platform.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/zikr_viewer_zikr_body.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/controller/bloc/zikr_viewer_bloc.dart';

class ZikrViewerPageBuilder extends StatelessWidget {
  const ZikrViewerPageBuilder({super.key, required this.dbContent});

  final DbContent dbContent;
  @override
  Widget build(BuildContext context) {
    final bool isDone = dbContent.count == 0;
    final body = ZikrViewerZikrBody(dbContent: dbContent);
    return GestureDetector(
      onTap: () {
        context.read<ZikrViewerBloc>().add(
          ZikrViewerDecreaseZikrEvent(content: dbContent),
        );
      },
      onLongPress: () {
        final snackBar = SnackBar(
          content: Text(
            dbContent.source,
            textAlign: TextAlign.center,
            softWrap: true,
          ),
          action: SnackBarAction(
            label: S.of(context).copy,
            onPressed: () {
              context.read<ZikrViewerBloc>().add(
                ZikrViewerCopyZikrEvent(content: dbContent),
              );
            },
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
      child: Stack(
        children: [
          Center(
            child: FittedBox(
              child: Text(
                key: ValueKey<int>(dbContent.count),
                isDone ? S.of(context).done : "${dbContent.count}".toArabicNumber(),
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withAlpha((.02 * 255).round()),
                  fontSize: 250,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (PlatformExtension.isDesktop)
            LayoutBuilder(
              builder: (context, viewport) => SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: viewport.maxHeight),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: body,
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(15).copyWith(bottom: 100),
              children: [body],
            ),
        ],
      ),
    );
  }
}
