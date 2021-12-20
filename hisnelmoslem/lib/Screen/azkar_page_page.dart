import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hisnelmoslem/page/settings.dart';
import 'package:hisnelmoslem/provider/fontsize.dart';
import 'package:hisnelmoslem/provider/settings_provider.dart';
import 'package:hisnelmoslem/provider/theme.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class AzkarPagePage extends StatefulWidget {
  AzkarPagePage(this.zikr);

  final zikr;
  @override
  _AzkarPagePageState createState() => _AzkarPagePageState();
}

class _AzkarPagePageState extends State<AzkarPagePage> {
  final _scaffoldKeyAzkarPagePag = GlobalKey<ScaffoldState>();
  PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context);
    final fontSize = Provider.of<FontSizeNotifier>(context);
    final setting = Provider.of<UserSettingsNotifier>(context);
    return Scaffold(
      key: _scaffoldKeyAzkarPagePag,
      appBar: AppBar(
        elevation: 20,
        centerTitle: true,
        title: new Text(
          widget.zikr.title,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25),
        ),
      ),
      body: new PageView.builder(
        controller: _pageController,
        reverse: true,
        itemCount: widget.zikr == null ? 0 : int.parse(widget.zikr.count),
        itemBuilder: (BuildContext context, int index) {
          return azkarCard2(index, fontSize, setting, theme);
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 4,
                child: new CupertinoSlider(
                  value: fontSize.getfontSize(),
                  thumbColor: Theme.of(context).accentColor,
                  activeColor: Theme.of(context).accentColor,
                  onChanged: (double value) {
                    setState(() {
                      fontSize.setfontSize(value);
                    });
                  },
                  divisions: 20,
                  min: 1.0,
                  max: 5.0,
                ),
              ),
              Expanded(
                  flex: 1,
                  child: IconButton(
                      icon: Icon(MdiIcons.abjadArabic),
                      onPressed: () {
                        setting.toggleTashkelStatus();
                      })),
              Expanded(
                  flex: 1,
                  child: IconButton(
                      icon: Icon(Theme.of(context).brightness == Brightness.dark
                          ? Icons.wb_sunny
                          : Icons.cloud),
                      onPressed: () {
                        theme.getTheme() == ThemeData.dark()
                            ? theme.setTheme(ThemeData.light())
                            : theme.setTheme(ThemeData.dark());
                      })),
              Expanded(
                  flex: 1,
                  child: IconButton(
                      icon: Icon(Icons.settings),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Settings()),
                        );
                      }))
            ],
          ),
        ),
      ),
    );
  }

  azkarCard2(index, fontSize, setting, ThemeNotifier theme) {
    int _counter = int.parse(widget.zikr.content[index].count);
    String text = setting.getTashkelStatus()
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
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Card(
            margin: EdgeInsets.all(10),
            elevation: 5,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onLongPress: () {
                final snackBar = SnackBar(
                  content: Text(
                    widget.zikr.content[index].source,
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                  action: SnackBarAction(
                      label: 'نسخ',
                      onPressed: () {
                        Share.share(source);
                      }),
                );

                _scaffoldKeyAzkarPagePag.currentState.showSnackBar(snackBar);
              },
              onTap: () {
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

                    setState(() {
                      _pageController.nextPage(
                          curve: Curves.easeIn,
                          duration: Duration(milliseconds: 500));
                    });
                  }
                }
              },
              child: Card(
                color: Colors.transparent,
                margin: EdgeInsets.all(0),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                child: ListView(
                  children: [
                    SizedBox(height: 50),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 50),
                          Text(
                            text,
                            textAlign: TextAlign.center,
                            softWrap: true,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                                fontSize: 10 * fontSize.getfontSize(),
                                fontWeight: FontWeight.w700),
                          ),
                          Text(
                            widget.zikr.content[index].fadl,
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            softWrap: true,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: MediaQuery.of(context).size.width / 2 - 100,
          child: Card(
            color: _counter != 0
                ? Theme.of(context).primaryColor
                : theme.getThemeString() == "green"
                    ? Colors.blue
                    : Colors.green,
            margin: EdgeInsets.only(bottom: 0, top: 0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40))),
            elevation: 5,
            child: Container(
              width: 200,
              padding: EdgeInsets.all(7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 15, 0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Share.share(text);
                      },
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).cardColor,
                        child: Icon(Icons.share),
                      ),
                    ),
                  ),

                  //
                  Container(
                    margin: EdgeInsets.fromLTRB(15, 0, 0, 0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        int cardnum = index + 1;
                        _launchURL(
                            'hassaneltantawy@gmail.com',
                            'تطبيق حصن المسلم: خطأ إملائي ',
                            ' السلام عليكم ورحمة الله وبركاته يوجد خطأ إملائي في' +
                                '<br>' +
                                'الموضوع: ' +
                                widget.zikr.title +
                                '<br>' +
                                'الذكر رقم: ' +
                                '$cardnum' +
                                '<br>' +
                                'النص: ' +
                                '$text' +
                                '<br>' +
                                'والصواب:' +
                                '<br>');
                      },
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).cardColor,
                        child: Icon(Icons.warning),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 15,
          right: MediaQuery.of(context).size.width / 2 -
              ((MediaQuery.of(context).size.width - 100) / 2),
          child: Container(
            width: MediaQuery.of(context).size.width - 100,
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: _counter != 0
                  ? Theme.of(context).primaryColor
                  : theme.getThemeString() == "green"
                      ? Colors.blue
                      : Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
                child: CircleAvatar(
              backgroundColor: Theme.of(context).cardColor,
              child: Text(
                '$_counter',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            )),
          ),
        )
      ],
    );
  }

  _launchURL(String toMailId, String subject, String body) async {
    var url = 'mailto:$toMailId?subject=$subject&body=$body';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
