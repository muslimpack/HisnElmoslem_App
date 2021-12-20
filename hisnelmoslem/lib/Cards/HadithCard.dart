import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hisnelmoslem/Widgets/OpenURL.dart';
import 'package:hisnelmoslem/models/Hadith.dart';

import 'package:flutter/rendering.dart';
import 'package:share/share.dart';
import 'package:provider/provider.dart';
import 'package:hisnelmoslem/Providers/AppSettings.dart';

class HadithCard extends StatelessWidget {
  final int index;
  final List<Hadith> hadith;

  // final double fontSize;
  final GlobalKey<ScaffoldState> scaffoldKey;

  HadithCard(
      {@required this.index,
      @required this.hadith,
      /* @required this.fontSize,*/

      @required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final appSettings = Provider.of<AppSettingsNotifier>(context);
    int cardnum = index + 1;
    String text = hadith[index].text;
    String darga = hadith[index].darga;
    String source = hadith[index].source;
    return GestureDetector(
      onLongPress: () {
        final snackBar = SnackBar(
          content: Text(
            source,
            textAlign: TextAlign.center,
            softWrap: true,
          ),
          action: SnackBarAction(
              label: 'نسخ',
              onPressed: () {
                // Some code to undo the change.
                ClipboardManager.copyToClipBoard(source);
              }),
        );

        // Find the Scaffold in the widget tree and use
        // it to show a SnackBar.
        // ignore: deprecated_member_use
        scaffoldKey.currentState.showSnackBar(snackBar);
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
                        ClipboardManager.copyToClipBoard(text + "\n" + darga)
                            .then((result) {
                          final snackBar = SnackBar(
                            content: Text('تم النسخ إلى الحافظة'),
                            action: SnackBarAction(
                              label: 'تم',
                              onPressed: () {},
                            ),
                          );
                          // ignore: deprecated_member_use
                          scaffoldKey.currentState.showSnackBar(snackBar);
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
                        Share.share(text + "\n" + darga);
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
                                  '$cardnum' +
                                  '\n' +
                                  'النص: ' +
                                  '$text' +
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
                text,
                textAlign: TextAlign.center,
                softWrap: true,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                    fontSize: 10 * appSettings.getfontSize(),
                    fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                darga,
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
