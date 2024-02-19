import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/app/data/app_data.dart';
import "package:hisnelmoslem/app/data/models/models.dart";
import 'package:hisnelmoslem/src/core/utils/email_manager.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/presentation/controller/fake_hadith_controller.dart';
import 'package:share/share.dart';

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
    return InkWell(
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
            onPressed: () {
              // Some code to undo the change.
              FlutterClipboard.copy(fakeHaith.source);
            },
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
      child: Card(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: !fakeHaith.isRead
                      ? const Icon(
                          Icons.check,
                        )
                      : Icon(
                          Icons.checklist,
                          color: mainColor,
                        ),
                ),
                Expanded(
                  child: IconButton(
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.copy,
                      color: mainColor,
                    ),
                    onPressed: () {
                      FlutterClipboard.copy(
                        "${fakeHaith.text}\n${fakeHaith.darga}",
                      ).then((result) {
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
                  child: IconButton(
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.camera_alt_rounded, color: mainColor),
                    onPressed: () {
                      fakeHadithController.shareFakehadithAsImage(fakeHaith);
                    },
                  ),
                ),
                Expanded(
                  child: IconButton(
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.share, color: mainColor),
                    onPressed: () {
                      Share.share("${fakeHaith.text}\n${fakeHaith.darga}");
                    },
                  ),
                ),
                Expanded(
                  child: IconButton(
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.report, color: orange),
                    onPressed: () {
                      EmailManager.sendMisspelledInFakeHadith(
                        fakeHaith: fakeHaith,
                      );
                    },
                  ),
                ),
              ],
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                fakeHaith.text,
                textAlign: TextAlign.center,
                softWrap: true,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: fakeHaith.isRead ? mainColor : null,
                  fontSize: appData.fontSize * 10,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                fakeHaith.darga,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                softWrap: true,
                style: TextStyle(
                  fontSize: appData.fontSize * 10,
                  color: mainColor,
                  //fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
