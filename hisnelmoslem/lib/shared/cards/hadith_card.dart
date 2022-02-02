import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:hisnelmoslem/models/fakeHaith.dart';
import 'package:hisnelmoslem/providers/app_settings.dart';
import 'package:hisnelmoslem/shared/functions/send_email.dart';
import 'package:hisnelmoslem/utils/fake_hadith_database_helper.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share/share.dart';
import 'package:provider/provider.dart';

import '../constant.dart';

class HadithCard extends StatefulWidget {
  final DbFakeHaith fakeHaith;
  // final double fontSize;
  final GlobalKey<ScaffoldState> scaffoldKey;

  HadithCard(
      {required this.fakeHaith,
      /* @required this.fontSize,*/

      required this.scaffoldKey});

  @override
  State<HadithCard> createState() => _HadithCardState();
}

class _HadithCardState extends State<HadithCard> {
  @override
  Widget build(BuildContext context) {
    final appSettings = Provider.of<AppSettingsNotifier>(context);

    return InkWell(
      onTap: () {
        setState(() {
          widget.fakeHaith.isRead = widget.fakeHaith.isRead == 1 ? 0 : 1;
          //
          if (widget.fakeHaith.isRead == 1) {
            fakeHadithDatabaseHelper.markAsRead(dbFakeHaith: widget.fakeHaith);
          } else {
            fakeHadithDatabaseHelper.markAsUnRead(
                dbFakeHaith: widget.fakeHaith);
          }
        });
      },
      onLongPress: () {
        final snackBar = SnackBar(
          content: Text(
            widget.fakeHaith.text,
            textAlign: TextAlign.center,
            softWrap: true,
          ),
          action: SnackBarAction(
              label: 'نسخ',
              onPressed: () {
                // Some code to undo the change.
                FlutterClipboard.copy(widget.fakeHaith.source);
              }),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
      child: Container(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: widget.fakeHaith.isRead == 0
                      ? Icon(
                          Icons.check,
                        )
                      : Icon(
                          Icons.checklist,
                          color: MAINCOLOR,
                        ),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                      splashRadius: 20,
                      padding: EdgeInsets.all(0),
                      icon: Icon(
                        Icons.copy,
                        color: Colors.blue.shade200,
                      ),
                      onPressed: () {
                        FlutterClipboard.copy(widget.fakeHaith.text +
                                "\n" +
                                widget.fakeHaith.darga)
                            .then((result) {
                          final snackBar = SnackBar(
                            content: Text('تم النسخ إلى الحافظة'),
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
                      padding: EdgeInsets.all(0),
                      icon: Icon(Icons.share, color: Colors.blue.shade200),
                      onPressed: () {
                        Share.share(widget.fakeHaith.text +
                            "\n" +
                            widget.fakeHaith.darga);
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
                                  '${(widget.fakeHaith.id) + 1}' +
                                  '\n' +
                                  'النص: ' +
                                  '${widget.fakeHaith.text}' +
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
                widget.fakeHaith.text,
                textAlign: TextAlign.center,
                softWrap: true,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                    color:
                        widget.fakeHaith.isRead == 1 ? MAINCOLOR : Colors.white,
                    fontSize: appSettings.getfontSize() * 10,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.fakeHaith.darga,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                softWrap: true,
                style: TextStyle(
                    fontSize: appSettings.getfontSize() * 10,
                    color: MAINCOLOR,
                    //fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Divider()
          ],
        ),
      ),
    );
  }
}
