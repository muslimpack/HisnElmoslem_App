import 'dart:convert';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hisnelmoslem/Providers/AppSettings.dart';
import 'package:hisnelmoslem/Shared/Functions/SendEmail.dart';
import 'package:hisnelmoslem/Shared/Widgets/Loading.dart';
import 'package:hisnelmoslem/Shared/constant.dart';
import 'package:hisnelmoslem/models/json/Zikr.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:wakelock/wakelock.dart';

class AzkarReadCard extends StatefulWidget {
  final int index;

  const AzkarReadCard({required this.index});

  @override
  _AzkarReadCardState createState() => _AzkarReadCardState();
}

class _AzkarReadCardState extends State<AzkarReadCard> {
  final _vReadScaffoldKey = GlobalKey<ScaffoldState>();
  List<Zikr> zikr = <Zikr>[];
  bool? isLoading = true;
  double? totalProgress = 0.0;
  Future<List<Zikr>> fetchAzkar() async {
    String data = await rootBundle.loadString('assets/json/azkar.json');

    var azkar = <Zikr>[];

    var azkarJson = json.decode(data);
    for (var azkarJson in azkarJson) {
      azkar.add(Zikr.fromJson(azkarJson));
    }

    return azkar;
  }

  @override
  void initState() {
    Wakelock.enable();
    getReady();
    super.initState();
  }

  getReady() async {
    await fetchAzkar().then((value) {
      setState(() {
        zikr.addAll(value);
      });
    });
    setState(() {
      isLoading = false;
    });
  }

  checkProgress() {
    int totalNum = 0, done = 0;
    totalNum = zikr[widget.index].content.length;
    for (Content item in zikr[widget.index].content) {
      if (int.parse(item.count) == 0) {
        done++;
      }
    }
    setState(() {
      totalProgress = done / totalNum;
    });
  }

  @override
  void dispose() {
    Wakelock.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appSettings = Provider.of<AppSettingsNotifier>(context);
    return isLoading!
        ? Loading()
        : Scaffold(
            key: _vReadScaffoldKey,
            appBar: AppBar(
              title: Text(zikr[widget.index].title,
                  style: TextStyle(fontFamily: "Uthmanic")),
              bottom: PreferredSize(
                preferredSize: Size(100, 5),
                child: LinearProgressIndicator(
                  value: totalProgress,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.blue,
                  ),
                  backgroundColor: Colors.grey,
                ),
              ),
            ),
            body: ScrollConfiguration(
              behavior: ScrollBehavior(),
              child: GlowingOverscrollIndicator(
                axisDirection: AxisDirection.down,
                color: Colors.black26,
                child: ListView.builder(
                  itemCount: zikr[widget.index].count == ""
                      ? 0
                      : int.parse(zikr[widget.index].count),
                  itemBuilder: (context, index) {
                    // String text = widget.zikr.content[index].text;
                    String text = appSettings.getTashkelStatus()
                        ? zikr[widget.index].content[index].text
                        : zikr[widget.index].content[index].text.replaceAll(
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
                    String source = zikr[widget.index].content[index].source;
                    String fadl = zikr[widget.index].content[index].fadl;
                    int cardnum = index + 1;
                    int _counter =
                        int.parse(zikr[widget.index].content[index].count);
                    return InkWell(
                      onTap: () {
                        if (_counter == 0) {
                          HapticFeedback.vibrate();
                        } else {
                          _counter--;

                          setState(() {
                            zikr[widget.index].content[index].count =
                                (int.parse(zikr[widget.index]
                                            .content[index]
                                            .count) -
                                        1)
                                    .toString();
                          });

                          if (_counter > 0) {
                          } else if (_counter == 0) {
                            HapticFeedback.vibrate();
                          }
                        }
                        checkProgress();
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
                                FlutterClipboard.copy(source).then((result) {
                                  final snackBar = SnackBar(
                                    content: Text('تم النسخ إلى الحافظة'),
                                    action: SnackBarAction(
                                      label: 'تم',
                                      onPressed: () {},
                                    ),
                                  );
                                  // ignore: deprecated_member_use
                                  _vReadScaffoldKey.currentState!
                                      // ignore: deprecated_member_use
                                      .showSnackBar(snackBar);
                                });
                              }),
                        );

                        // Find the Scaffold in the widget tree and use
                        // it to show a SnackBar.
                        // ignore: deprecated_member_use
                        _vReadScaffoldKey.currentState!.showSnackBar(snackBar);
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
                                    icon: Icon(Icons.copy,
                                        color: Colors.blue.shade200),
                                    onPressed: () {
                                      FlutterClipboard.copy(text + "\n" + fadl)
                                          .then((result) {
                                        final snackBar = SnackBar(
                                          content: Text('تم النسخ إلى الحافظة'),
                                          action: SnackBarAction(
                                            label: 'تم',
                                            onPressed: () {},
                                          ),
                                        );
                                        // ignore: deprecated_member_use
                                        _vReadScaffoldKey.currentState!
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
                                    icon: Icon(Icons.report,
                                        color: Colors.orange),
                                    onPressed: () {
                                      sendEmail(
                                          toMailId: 'hassaneltantawy@gmail.com',
                                          subject:
                                              'تطبيق حصن المسلم: خطأ إملائي ',
                                          body:
                                              ' السلام عليكم ورحمة الله وبركاته يوجد خطأ إملائي في' +
                                                  '\n' +
                                                  'الموضوع: ' +
                                                  zikr[widget.index].title +
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
                                  fontSize: appSettings.getfontSize() * 10,
                                  color: int.parse(zikr[widget.index]
                                              .content[index]
                                              .count) ==
                                          0
                                      ? MAINCOLOR
                                      : Colors.white,
                                  //fontSize: 20,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                            child: Text(
                              zikr[widget.index].content[index].fadl,
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
                                zikr[widget.index].content[index].count,
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
                                appSettings.setfontSize(
                                    appSettings.getfontSize() + 0.3);
                              });
                            })),
                    Expanded(
                        flex: 1,
                        child: IconButton(
                            icon: Icon(MdiIcons.formatFontSizeDecrease),
                            onPressed: () {
                              setState(() {
                                appSettings.setfontSize(
                                    appSettings.getfontSize() - 0.3);
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
                  ],
                ),
              ),
            ),
          );
  }
}
