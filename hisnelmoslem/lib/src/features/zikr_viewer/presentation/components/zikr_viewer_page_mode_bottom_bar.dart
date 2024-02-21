import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/font_settings.dart';
import 'package:hisnelmoslem/src/core/utils/email_manager.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content_extension.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/controller/azkar_read_page_controller.dart';

class ZikrViewerPageModeBottomBar extends StatelessWidget {
  final AzkarReadPageController controller;

  const ZikrViewerPageModeBottomBar({
    super.key,
    required this.controller,
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
                final text = await controller.activeZikr.getPlainText();
                await Clipboard.setData(
                  ClipboardData(text: "$text\n${controller.activeZikr.fadl}"),
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
            flex: 3,
            child: FontSettingsToolbox(
              controllerToUpdate: controller,
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
              onPressed: () async {
                final text = await controller.activeZikr.getPlainText();
                EmailManager.sendMisspelledInZikrWithText(
                  subject: controller.zikrTitle!.name,
                  cardNumber: (controller.currentPage + 1).toString(),
                  text: text,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
