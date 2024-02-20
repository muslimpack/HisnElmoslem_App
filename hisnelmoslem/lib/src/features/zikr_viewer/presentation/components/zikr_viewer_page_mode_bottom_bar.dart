// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/font_settings.dart';
import 'package:hisnelmoslem/src/core/utils/email_manager.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/controller/azkar_read_page_controller.dart';

class ZikrViewerPageModeBottomBar extends StatelessWidget {
  final AzkarReadPageController controller;
  final String? text;
  final String? fadl;
  final int? cardNumber;
  const ZikrViewerPageModeBottomBar({
    super.key,
    required this.controller,
    required this.text,
    required this.fadl,
    required this.cardNumber,
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
              onPressed: () {
                FlutterClipboard.copy("${text!}\n${fadl!}").then((result) {
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
              onPressed: () {
                EmailManager.sendMisspelledInZikrWithText(
                  subject: controller.zikrTitle!.name,
                  cardNumber: cardNumber.toString(),
                  text: text!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
