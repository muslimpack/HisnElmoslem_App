import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hisnelmoslem/Providers/AppSettings.dart';
import 'package:hisnelmoslem/Widgets/OpenURL.dart';
import 'package:hisnelmoslem/Widgets/constant.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class VRread extends StatefulWidget {
  final zikr;

  const VRread({@required this.zikr});

  @override
  _VRreadState createState() => _VRreadState();
}

class _VRreadState extends State<VRread> {
  final _vReadScaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final appSettings = Provider.of<AppSettingsNotifier>(context);
    return Scaffold(
      key: _vReadScaffoldKey,
      appBar: AppBar(
        title: Text(widget.zikr.title),
      ),
      body: ScrollConfiguration(
        behavior: ScrollBehavior(),
        child: GlowingOverscrollIndicator(
          axisDirection: AxisDirection.down,
          color: Colors.black26,
          child: ListView.builder(
            itemCount: widget.zikr.count == null || widget.zikr.count == ""
                ? 0
                : int.parse(widget.zikr.count),
            itemBuilder: (context, index) {
             // String text = widget.zikr.content[index].text;
              String text = appSettings.getTashkelStatus()
                  ? widget.zikr.content[index].text
                  : widget.zikr.content[index].text.replaceAll(
                //* لحذف التشكيل
                  new RegExp(String.fromCharCodes([
                    1617,
                    124,
                    1614,
                    124,
                    1611,
                    124,
                    1615,
                    124,
                    1612,
                    124,
                    1616,
                    124,
                    1613,
                    124,
                    1618
                  ])),
                  "");
              String source = widget.zikr.content[index].source;
              String fadl = widget.zikr.content[index].fadl;
              int cardnum = index + 1;
              int _counter = int.parse(widget.zikr.content[index].count);
              return InkWell(
                onTap: () {
                  print("tapped" +
                      '$_counter' +
                      '${widget.zikr.content[index].count}');
                  if (_counter == 0) {
                    HapticFeedback.vibrate();
                  } else {
                    _counter--;

                    setState(() {
                      widget.zikr.content[index].count =
                          (int.parse(widget.zikr.content[index].count) - 1)
                              .toString();
                    });

                    if (_counter > 0) {
                    } else if (_counter == 0) {
                      HapticFeedback.vibrate();
                    }
                  }
                },
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
                          ClipboardManager.copyToClipBoard(source)
                              .then((result) {
                            final snackBar = SnackBar(
                              content: Text('تم النسخ إلى الحافظة'),
                              action: SnackBarAction(
                                label: 'تم',
                                onPressed: () {},
                              ),
                            );
                            // ignore: deprecated_member_use
                            _vReadScaffoldKey.currentState
                                // ignore: deprecated_member_use
                                .showSnackBar(snackBar);
                          });
                        }),
                  );

                  // Find the Scaffold in the widget tree and use
                  // it to show a SnackBar.
                  // ignore: deprecated_member_use
                  _vReadScaffoldKey.currentState.showSnackBar(snackBar);
                },
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: IconButton(
                              splashRadius: 20,
                              padding: EdgeInsets.all(0),
                              icon:
                                  Icon(Icons.copy, color: Colors.blue.shade200),
                              onPressed: () {
                                ClipboardManager.copyToClipBoard(
                                        text + "\n" + fadl)
                                    .then((result) {
                                  final snackBar = SnackBar(
                                    content: Text('تم النسخ إلى الحافظة'),
                                    action: SnackBarAction(
                                      label: 'تم',
                                      onPressed: () {},
                                    ),
                                  );
                                  // ignore: deprecated_member_use
                                  _vReadScaffoldKey.currentState
                                      // ignore: deprecated_member_use
                                      .showSnackBar(snackBar);
                                });
                              }),
                        ),
                        Expanded(
                          flex: 1,
                          child: IconButton(
                              splashRadius: 20,
                              padding: EdgeInsets.all(0),
                              icon: Icon(Icons.share,
                                  color: Colors.blue.shade200),
                              onPressed: () {
                                Share.share(text + "\n" + fadl);
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
                                            widget.zikr.title +
                                            '\n' +
                                            'الذكر رقم: ' +
                                            '$cardnum' +
                                            '\n' +
                                            'النص: ' +
                                            '$text' +
                                            '\n' +
                                            'والصواب:' +
                                            '\n');
                              }),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 5),
                      child: Text(
                        text,
                        textAlign: TextAlign.center,
                        softWrap: true,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                            fontSize: 10 * appSettings.getfontSize(),
                            color:
                                int.parse(widget.zikr.content[index].count) == 0
                                    ? MAINCOLOR
                                    : Colors.white,
                            //fontSize: 20,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                      child: Text(
                        widget.zikr.content[index].fadl,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        softWrap: true,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          widget.zikr.content[index].count,
                          style: TextStyle(color: MAINCOLOR),
                        ),
                      ),
                    ),
                    Divider(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        //elevation: 20,
        color: Theme.of(context).primaryColor,
        child: Container(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  flex: 1,
                  child: IconButton(
                      icon: Icon(MdiIcons.formatFontSizeIncrease),
                      onPressed: () {
                        setState(() {
                          appSettings
                              .setfontSize(appSettings.getfontSize() + 0.3);
                        });
                      })),
              Expanded(
                  flex: 1,
                  child: IconButton(
                      icon: Icon(MdiIcons.formatFontSizeDecrease),
                      onPressed: () {
                        setState(() {
                          appSettings
                              .setfontSize(appSettings.getfontSize() - 0.3);
                        });
                      })),
              Expanded(
                  flex: 1,
                  child: IconButton(
                      icon: Icon(MdiIcons.abjadArabic),
                      onPressed: () {
                        setState(() {
                          appSettings.toggleTashkelStatus();
                        });

                      })),
              /*   */
            ],
          ),
        ),
      ),
    );
  }
}
