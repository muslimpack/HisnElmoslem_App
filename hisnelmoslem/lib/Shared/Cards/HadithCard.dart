import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:hisnelmoslem/Shared/Functions/SendEmail.dart';
import 'package:hisnelmoslem/models/AzkarDb/DbFakeHaith.dart';
import 'package:share/share.dart';
import 'package:provider/provider.dart';
import 'package:hisnelmoslem/Providers/AppSettings.dart';

class HadithCard extends StatelessWidget {
  final DbFakeHaith fakeHaith;
  // final double fontSize;
  final GlobalKey<ScaffoldState> scaffoldKey;

  HadithCard(
      {required this.fakeHaith,
      /* @required this.fontSize,*/

      required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final appSettings = Provider.of<AppSettingsNotifier>(context);

    return GestureDetector(
      onLongPress: () {
        final snackBar = SnackBar(
          content: Text(
            fakeHaith.text,
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

        // Find the Scaffold in the widget tree and use
        // it to show a SnackBar.
        // ignore: deprecated_member_use
        scaffoldKey.currentState!.showSnackBar(snackBar);
      },
      child: Container(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: IconButton(
                      splashRadius: 20,
                      padding: EdgeInsets.all(0),
                      icon: Icon(Icons.copy, color: Colors.blue.shade200),
                      onPressed: () {
                        FlutterClipboard.copy(
                                fakeHaith.text + "\n" + fakeHaith.darga)
                            .then((result) {
                          final snackBar = SnackBar(
                            content: Text('تم النسخ إلى الحافظة'),
                            action: SnackBarAction(
                              label: 'تم',
                              onPressed: () {},
                            ),
                          );
                          // ignore: deprecated_member_use
                          scaffoldKey.currentState!.showSnackBar(snackBar);
                        });
                      }),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                      splashRadius: 20,
                      padding: EdgeInsets.all(0),
                      icon: Icon(Icons.share, color: Colors.blue.shade200),
                      onPressed: () {
                        Share.share(fakeHaith.text + "\n" + fakeHaith.darga);
                      }),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                      splashRadius: 20,
                      padding: EdgeInsets.all(0),
                      icon: Icon(Icons.report, color: Colors.orange),
                      onPressed: () {
                        sendEmail(
                          toMailId: 'hassaneltantawy@gmail.com',
                          subject: 'تطبيق حصن المسلم: خطأ إملائي ',
                          body:
                              ' السلام عليكم ورحمة الله وبركاته يوجد خطأ إملائي في' +
                                  '\n' +
                                  'الموضوع: ' +
                                  'أحاديث لا تصح' +
                                  '\n' +
                                  'البطاقة رقم: ' +
                                  '${(fakeHaith.id) + 1}' +
                                  '\n' +
                                  'النص: ' +
                                  '${fakeHaith.text}' +
                                  '\n' +
                                  'والصواب:' +
                                  '\n',
                        );
                      }),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                fakeHaith.text,
                textAlign: TextAlign.center,
                softWrap: true,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                    fontSize: appSettings.getfontSize() * 10,
                    fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                fakeHaith.darga,
                textAlign: TextAlign.start,
                textDirection: TextDirection.rtl,
                softWrap: true,
                style: TextStyle(color: Colors.blue),
              ),
            ),
            Divider()
          ],
        ),
      ),
    );
  }
}
