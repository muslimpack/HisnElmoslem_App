import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/repos/app_data.dart';
import 'package:hisnelmoslem/src/core/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/src/core/utils/email_manager.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/data/models/fake_haith.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/presentation/controller/fake_hadith_controller.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/screens/share_as_image.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:share_plus/share_plus.dart';

class HadithCard extends StatelessWidget {
  final DbFakeHaith fakeHaith;

  // final double fontSize;
  final GlobalKey<ScaffoldState> scaffoldKey;

  HadithCard({
    super.key,
    required this.fakeHaith,
    /* @required this.fontSize,*/

    required this.scaffoldKey,
  });

  final FakeHadithController fakeHadithController =
      Get.put(FakeHadithController());

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: !fakeHaith.isRead
                    ? const Icon(
                        Icons.check,
                      )
                    : const Icon(
                        Icons.checklist,
                      ),
              ),
              Expanded(
                child: IconButton(
                  splashRadius: 20,
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.copy,
                  ),
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(
                        text: "${fakeHaith.text}\n${fakeHaith.darga}",
                      ),
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
                  icon: const Icon(Icons.camera_alt_rounded),
                  onPressed: () {
                    final DbContent dbContent = DbContent(
                      id: -1,
                      titleId: -1,
                      orderId: fakeHaith.id,
                      content: fakeHaith.text,
                      fadl: fakeHaith.darga,
                      source: fakeHaith.source,
                      count: 0,
                      favourite: false,
                    );

                    transitionAnimation.circleReval(
                      context: Get.context!,
                      goToPage: ShareAsImage(dbContent: dbContent),
                    );
                  },
                ),
              ),
              Expanded(
                child: IconButton(
                  splashRadius: 20,
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    Share.share("${fakeHaith.text}\n${fakeHaith.darga}");
                  },
                ),
              ),
              Expanded(
                child: IconButton(
                  splashRadius: 20,
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.report),
                  onPressed: () {
                    EmailManager.sendMisspelledInFakeHadith(
                      fakeHaith: fakeHaith,
                    );
                  },
                ),
              ),
            ],
          ),
          const Divider(height: 0),
          InkWell(
            onTap: () {
              fakeHadithController.toggleReadState(fakeHaith: fakeHaith);
            },
            onLongPress: () {
              final snackBar = SnackBar(
                content: Text(
                  fakeHaith.source,
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
                action: SnackBarAction(
                  label: "copy".tr,
                  onPressed: () async {
                    // Some code to undo the change.
                    await Clipboard.setData(
                      ClipboardData(text: fakeHaith.source),
                    );
                  },
                ),
              );

              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
            child: Container(
              constraints: const BoxConstraints(minHeight: 150),
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  Text(
                    fakeHaith.text,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: AppData.instance.fontSize * 10,
                    ),
                  ),
                  Text(
                    fakeHaith.darga,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    softWrap: true,
                    style: TextStyle(
                      fontSize: AppData.instance.fontSize * 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
