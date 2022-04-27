import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/controllers/app_data_controllers.dart';
import 'package:hisnelmoslem/controllers/fake_hadith_controller.dart';
import 'package:hisnelmoslem/models/fake_haith.dart';
import 'package:hisnelmoslem/shared/functions/send_email.dart';
import 'package:share/share.dart';

import '../constants/constant.dart';

class HadithCard extends StatelessWidget {
  final DbFakeHaith fakeHaith;
  // final double fontSize;
  final GlobalKey<ScaffoldState> scaffoldKey;

  HadithCard(
      {Key? key,
      required this.fakeHaith,
      /* @required this.fontSize,*/

      required this.scaffoldKey})
      : super(key: key);

  final FakeHadithController fakeHadithController =
      Get.put(FakeHadithController());
  final AppDataController appDataController = Get.put(AppDataController());
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
              label: 'نسخ',
              onPressed: () {
                // Some code to undo the change.
                FlutterClipboard.copy(fakeHaith.source);
              }),
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
                      : const Icon(
                          Icons.checklist,
                          color: mainColor,
                        ),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                      splashRadius: 20,
                      padding: const EdgeInsets.all(0),
                      icon: const Icon(
                        Icons.copy,
                        color: mainColor,
                      ),
                      onPressed: () {
                        FlutterClipboard.copy(
                                fakeHaith.text + "\n" + fakeHaith.darga)
                            .then((result) {
                          final snackBar = SnackBar(
                            content: const Text('تم النسخ إلى الحافظة'),
                            action: SnackBarAction(
                              label: 'تم',
                              onPressed: () {},
                            ),
                          );

                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        });
                      }),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                      splashRadius: 20,
                      padding: const EdgeInsets.all(0),
                      icon: const Icon(Icons.share, color: mainColor),
                      onPressed: () {
                        Share.share(fakeHaith.text + "\n" + fakeHaith.darga);
                      }),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                      splashRadius: 20,
                      padding: const EdgeInsets.all(0),
                      icon: Icon(Icons.report, color: orange),
                      onPressed: () {
                        sendEmail(
                          toMailId: 'hassaneltantawy@gmail.com',
                          subject: 'تطبيق حصن المسلم: خطأ إملائي ',
                          body:
                              ' السلام عليكم ورحمة الله وبركاته يوجد خطأ إملائي في'
                              '\n'
                              'الموضوع: '
                              'أحاديث لا تصح'
                              '\n'
                              'البطاقة رقم: '
                              '${(fakeHaith.id) + 1}'
                              '\n'
                              'النص: '
                              "${fakeHaith.text}"
                              '\n'
                              'والصواب:'
                              '\n',
                        );
                      }),
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
                    fontSize: appDataController.fontSize * 10,
                    fontWeight: FontWeight.bold),
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
                    fontSize: appDataController.fontSize * 10,
                    color: mainColor,
                    //fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
