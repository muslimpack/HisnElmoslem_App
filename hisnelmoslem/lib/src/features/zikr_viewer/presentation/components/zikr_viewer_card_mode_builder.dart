// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/extensions/string_extension.dart';
import 'package:hisnelmoslem/src/core/repos/app_data.dart';
import 'package:hisnelmoslem/src/core/shared/dialogs/commentary_dialog.dart';
import 'package:hisnelmoslem/src/core/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/text_divider.dart';
import 'package:hisnelmoslem/src/core/utils/email_manager.dart';
import 'package:hisnelmoslem/src/features/home/presentation/controller/dashboard_controller.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/screens/share_as_image.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content_extension.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/zikr_content_builder.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/controller/azkar_read_card_controller.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share/share.dart';

class ZikrViewerCardBuilder extends StatelessWidget {
  final int index;
  final AzkarReadCardController controller;
  final DashboardController dashboardController;

  const ZikrViewerCardBuilder({
    super.key,
    required this.index,
    required this.controller,
    required this.dashboardController,
  });

  @override
  Widget build(BuildContext context) {
    final dbContent = controller.zikrContent[index];
    final String text = appData.isDiacriticsEnabled
        ? dbContent.content
        : dbContent.content.removeDiacritics;
    final String source = dbContent.source;
    final String fadl = dbContent.fadl;
    final int cardNum = index + 1;
    int counter = dbContent.count;

    return InkWell(
      onTap: () {
        counter = controller.decreaseCount(counter, index);
      },
      onLongPress: () {
        final snackBar = SnackBar(
          content: Text(
            source,
            textAlign: TextAlign.center,
            softWrap: true,
          ),
          action: SnackBarAction(
            label: "copy".tr,
            onPressed: () async {
              await Clipboard.setData(
                ClipboardData(text: source),
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
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: IconButton(
                    splashRadius: 20,
                    icon: const Icon(MdiIcons.comment),
                    onPressed: () {
                      showCommentaryDialog(
                        context: Get.context!,
                        contentId: dbContent.id,
                      );
                    },
                  ),
                ),
                Expanded(
                  child: IconButton(
                    splashRadius: 20,
                    icon: const Icon(MdiIcons.camera),
                    onPressed: () {
                      transitionAnimation.circleReval(
                        context: Get.context!,
                        goToPage: ShareAsImage(
                          dbContent: dbContent,
                        ),
                      );
                    },
                  ),
                ),
                if (!dbContent.favourite)
                  IconButton(
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.favorite_border,
                    ),
                    onPressed: () {
                      dbContent.favourite = true;
                      controller.update();
                      dashboardController.addContentToFavourite(
                        dbContent,
                      );
                    },
                  )
                else
                  IconButton(
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.favorite,
                    ),
                    onPressed: () {
                      dbContent.favourite = false;
                      controller.update();
                      dashboardController.removeContentFromFavourite(
                        dbContent,
                      );
                    },
                  ),
                Expanded(
                  child: IconButton(
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.copy,
                    ),
                    onPressed: () async {
                      final text = await dbContent.getPlainText();

                      await Clipboard.setData(
                        ClipboardData(text: "$text\n$fadl"),
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
                ),
                Expanded(
                  child: IconButton(
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.share,
                    ),
                    onPressed: () {
                      Share.share("$text\n$fadl");
                    },
                  ),
                ),
                Expanded(
                  child: IconButton(
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.report,
                      color: Colors.orange,
                    ),
                    onPressed: () {
                      EmailManager.sendMisspelledInZikrWithText(
                        subject: controller.zikrTitle!.name,
                        cardNumber: cardNum.toString(),
                        text: text,
                      );
                    },
                  ),
                ),
              ],
            ),
            const Divider(thickness: 2),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  ZikrContentBuilder(
                    dbContent: dbContent,
                    enableDiacritics: appData.isDiacriticsEnabled,
                    fontSize: appData.fontSize * 10,
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
                        fontSize: appData.fontSize * 8,
                        height: 2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Divider(thickness: 2),
            Padding(
              padding: const EdgeInsets.all(10),
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Text(
                  dbContent.count.toString(),
                  style: TextStyle(
                    fontSize: appData.fontSize * 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
