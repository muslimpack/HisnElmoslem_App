import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/repos/app_data.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/zikr_content_builder.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/controller/azkar_read_page_controller.dart';

class ZikrViewerPageBuilder extends StatelessWidget {
  const ZikrViewerPageBuilder({
    super.key,
    required this.controller,
    required this.index,
  });

  final int index;
  final AzkarReadPageController controller;
  @override
  Widget build(BuildContext context) {
    final DbContent dbContent = controller.zikrContent[index];

    final bool isDone = dbContent.count == 0;
    return GestureDetector(
      onTap: () {
        controller.decreaseCount();
      },
      onLongPress: () {
        final snackBar = SnackBar(
          content: Text(
            controller.activeZikr.source,
            textAlign: TextAlign.center,
            softWrap: true,
          ),
          action: SnackBarAction(
            label: "copy".tr,
            onPressed: () async {
              // Some code to undo the change.

              await Clipboard.setData(
                ClipboardData(text: controller.activeZikr.source),
              );
              final snackBar = SnackBar(
                content: Text("copied to clipboard".tr),
                action: SnackBarAction(
                  label: "done".tr,
                  onPressed: () {},
                ),
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
                isDone ? "done".tr : "${dbContent.count}",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary.withOpacity(.05),
                  fontSize: 250,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 10),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 5),
                child: ZikrContentBuilder(
                  dbContent: dbContent,
                  enableDiacritics: appData.isDiacriticsEnabled,
                  fontSize: appData.fontSize * 10,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                child: Text(
                  dbContent.fadl,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: appData.fontSize * 10,
                    height: 2,

                    //fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
