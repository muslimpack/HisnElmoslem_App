import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_object.dart';
import 'package:hisnelmoslem/src/core/repos/app_data.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/text_divider.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/zikr_content_builder.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/controller/bloc/zikr_page_viewer_bloc.dart';

class ZikrViewerPageBuilder extends StatelessWidget {
  const ZikrViewerPageBuilder({
    super.key,
    required this.dbContent,
  });

  final DbContent dbContent;
  @override
  Widget build(BuildContext context) {
    final bool isDone = dbContent.count == 0;
    return GestureDetector(
      onTap: () {
        context
            .read<ZikrPageViewerBloc>()
            .add(ZikrPageViewerDecreaseActiveZikrEvent());
      },
      onLongPress: () {
        final snackBar = SnackBar(
          content: Text(
            dbContent.source,
            textAlign: TextAlign.center,
            softWrap: true,
          ),
          action: SnackBarAction(
            label: "copy".tr,
            onPressed: () async {
              context
                  .read<ZikrPageViewerBloc>()
                  .add(ZikrPageViewerCopyActiveZikrEvent());
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
                isDone ? "done".tr : "${dbContent.count}".toArabicNumber(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary.withOpacity(.02),
                  fontSize: 250,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(15),
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
        ],
      ),
    );
  }
}
