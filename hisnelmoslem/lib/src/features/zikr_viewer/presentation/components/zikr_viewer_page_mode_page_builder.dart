// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/extensions/string_extension.dart';
import 'package:hisnelmoslem/src/core/repos/app_data.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/zikr_content_builder.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/controller/azkar_read_page_controller.dart';

class ZikrViewerPageBuilder extends StatelessWidget {
  const ZikrViewerPageBuilder({
    super.key,
    required this.source,
    required this.controller,
    required this.index,
  });

  final String? source;
  final int index;
  final AzkarReadPageController controller;
  @override
  Widget build(BuildContext context) {
    final DbContent dbContent = controller.zikrContent[index];
    final String text = appData.isDiacriticsEnabled
        ? dbContent.content
        : dbContent.content.removeDiacritics;
    final bool containsAyah = text.contains("﴿");
    final bool isDone = dbContent.count == 0;
    return GestureDetector(
      onTap: () {
        controller.decreaseCount();
      },
      onLongPress: () {
        final snackBar = SnackBar(
          content: Text(
            source!,
            textAlign: TextAlign.center,
            softWrap: true,
          ),
          action: SnackBarAction(
            label: "copy".tr,
            onPressed: () {
              // Some code to undo the change.
              FlutterClipboard.copy(source!).then((result) {
                final snackBar = SnackBar(
                  content: Text("copied to clipboard".tr),
                  action: SnackBarAction(
                    label: "done".tr,
                    onPressed: () {},
                  ),
                );

                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              });
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
                  color: Theme.of(context).colorScheme.primary.withOpacity(.2),
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
