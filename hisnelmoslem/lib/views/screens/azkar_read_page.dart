import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/controllers/dashboard_controller.dart';
import 'package:hisnelmoslem/shared/Widgets/Loading.dart';
import 'package:hisnelmoslem/shared/constant.dart';
import 'package:hisnelmoslem/utils/azkar_database_helper.dart';
import 'package:hisnelmoslem/models/zikr_content.dart';
import 'package:hisnelmoslem/models/zikr_title.dart';
import 'package:hisnelmoslem/providers/app_settings.dart';
import 'package:hisnelmoslem/shared/functions/send_email.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:wakelock/wakelock.dart';
// import 'package:hisnelmoslem/AppManager/VolumeButton.dart';

class AzkarReadPage extends StatefulWidget {
  final int index;

  const AzkarReadPage({required this.index});

  @override
  _AzkarReadPageState createState() => _AzkarReadPageState();
}

class _AzkarReadPageState extends State<AzkarReadPage> {
  DashboardController dashboardController = Get.put(DashboardController());
  //
  final _hReadScaffoldKey = GlobalKey<ScaffoldState>();
  PageController _pageController = PageController(initialPage: 0);
  //
  List<DbContent> zikrContent = <DbContent>[];
  DbTitle? zikrTitle;
  //
  int currentPage = 0;
  bool isLoading = true;
  double? totalProgress = 0.0;
  //
  static const _volumeBtnChannel = MethodChannel("volume_button_channel");

  @override
  void initState() {
    //
    _volumeBtnChannel.setMethodCallHandler((call) {
      if (call.method == "volumeBtnPressed") {
        if (call.arguments == "VOLUME_DOWN_UP" ||
            call.arguments == "VOLUME_UP_UP") {
          decreaseCount();
        }
      }

      return Future.value(null);
    });
    //
    _pageController = PageController(initialPage: 0);
    Wakelock.enable();
    getReady();
    super.initState();
  }

  getReady() async {
    await azkarDatabaseHelper
        .getTitleByIndex(index: widget.index)
        .then((value) => zikrTitle = value);
    //
    await azkarDatabaseHelper
        .getContentsByTitleIndex(index: widget.index)
        .then((value) => zikrContent = value);

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  _onPageViewChange(int page) {
    setState(() {
      currentPage = page;
    });
  }

  decreaseCount() {
    int _counter = zikrContent[currentPage].count;
    if (_counter == 0) {
      HapticFeedback.vibrate();
    } else {
      _counter--;

      setState(() {
        zikrContent[currentPage].count = ((zikrContent[currentPage].count) - 1);
      });

      if (_counter > 0) {
      } else if (_counter == 0) {
        HapticFeedback.vibrate();

        setState(() {
          _pageController.nextPage(
              curve: Curves.easeIn, duration: Duration(milliseconds: 500));
        });
      }
    }
    checkProgress();
  }

  checkProgress() {
    int totalNum = 0, done = 0;
    totalNum = zikrContent.length;
    for (var i = 0; i < zikrContent.length; i++) {
      if (zikrContent[i].count == 0) {
        done++;
      }
    }
    setState(() {
      totalProgress = done / totalNum;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appSettings = Provider.of<AppSettingsNotifier>(context);
    String? text = "";
    String? source = "";
    String? fadl = "";
    int? cardnum = 0;
    if (!isLoading) {
      text = appSettings.getTashkelStatus()
          ? zikrContent[currentPage].content
          : zikrContent[currentPage].content.replaceAll(
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

      source = zikrContent[currentPage].source;
      fadl = zikrContent[currentPage].fadl;
      cardnum = currentPage + 1;
    }

    return isLoading
        ? Loading()
        : Scaffold(
            key: _hReadScaffoldKey,
            appBar: AppBar(
              title: Text(zikrTitle!.name,
                  style: TextStyle(fontFamily: "Uthmanic")),
              actions: [
                zikrContent[currentPage].favourite == 0
                    ? IconButton(
                        splashRadius: 20,
                        padding: EdgeInsets.all(0),
                        icon: Icon(Icons.favorite_border,
                            color: Colors.blue.shade200),
                        onPressed: () {
                          setState(() {
                            zikrContent[currentPage].favourite = 1;
                          });
                          //
                          dashboardController
                              .addContentToFavourite(zikrContent[currentPage]);
                          //
                          // dashboardController.update();
                        })
                    : IconButton(
                        splashRadius: 20,
                        padding: EdgeInsets.all(0),
                        icon: Icon(
                          Icons.favorite,
                          color: Colors.blue.shade200,
                        ),
                        onPressed: () {
                          setState(() {
                            zikrContent[currentPage].favourite = 0;
                          });

                          dashboardController.removeContentFromFavourite(
                              zikrContent[currentPage]);
                        }),
                IconButton(
                    splashRadius: 20,
                    padding: EdgeInsets.all(0),
                    icon: Icon(Icons.share, color: Colors.blue.shade200),
                    onPressed: () {
                      Share.share(text! + "\n" + fadl!);
                    }),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Text(
                      zikrContent[currentPage].count.toString(),
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                )
              ],
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
                axisDirection: AxisDirection.left,
                color: Colors.black26,
                child: PageView.builder(
                  onPageChanged: _onPageViewChange,
                  controller: _pageController,
                  itemCount: zikrContent.length.isNaN ? 0 : zikrContent.length,
                  itemBuilder: (context, index) {
                    /* I repeated this code here to prevent text to be look like
                       the text in the next page when we swipe */
                    String text = appSettings.getTashkelStatus()
                        ? zikrContent[index].content
                        : zikrContent[index].content.replaceAll(
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
                    return InkWell(
                      onTap: () {
                        decreaseCount();
                      },
                      onLongPress: () {
                        final snackBar = SnackBar(
                          content: Text(
                            source!,
                            textAlign: TextAlign.center,
                            softWrap: true,
                          ),
                          action: SnackBarAction(
                              label: 'نسخ',
                              onPressed: () {
                                // Some code to undo the change.
                                FlutterClipboard.copy(source!).then((result) {
                                  final snackBar = SnackBar(
                                    content: Text('تم النسخ إلى الحافظة'),
                                    action: SnackBarAction(
                                      label: 'تم',
                                      onPressed: () {},
                                    ),
                                  );

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                });
                              }),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      },
                      child: ListView(
                        physics: ClampingScrollPhysics(),
                        padding: EdgeInsets.only(top: 10),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 20, 10, 5),
                            child: Text(
                              text,
                              textAlign: TextAlign.center,
                              softWrap: true,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                  fontSize: appSettings.getfontSize() * 10,
                                  color: zikrContent[index].count == 0
                                      ? MAINCOLOR
                                      : Colors.white,
                                  // fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                            child: Text(
                              zikrContent[index].fadl,
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                              softWrap: true,
                              style: TextStyle(
                                  fontSize: appSettings.getfontSize() * 10,
                                  color: MAINCOLOR,
                                  //fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
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
                          splashRadius: 20,
                          padding: EdgeInsets.all(0),
                          icon: Icon(Icons.copy, color: Colors.blue.shade200),
                          onPressed: () {
                            FlutterClipboard.copy(text! + "\n" + fadl!)
                                .then((result) {
                              final snackBar = SnackBar(
                                content: Text('تم النسخ إلى الحافظة'),
                                action: SnackBarAction(
                                  label: 'تم',
                                  onPressed: () {},
                                ),
                              );

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            });
                          }),
                    ),
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
                                        zikrTitle!.name +
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
              ),
            ),
          );
  }
}
