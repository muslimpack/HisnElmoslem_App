import 'dart:convert';

import 'package:Azkar/settings.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class FakeHadith extends StatefulWidget {
  @override
  _FakeHadithState createState() => _FakeHadithState();
}

class _FakeHadithState extends State<FakeHadith> {
  String zikrorg;
  String zikrtashkel;
  double fontSize = 2.6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 20,
        centerTitle: true,
        title: new Text(
          "أحاديث لا تصح",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25),
        ),
      ),
      //

      body: new Container(
        child: Center(
          child: new FutureBuilder(
            future: DefaultAssetBundle.of(context)
                .loadString("json/fakehadith.json"),
            builder: (context, snapshot) {
              //decode json file

              var mydata = json.decode(snapshot.data.toString());

              return new ListView.builder(
                itemCount: mydata == null ? 0 : mydata.length,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                itemBuilder: (
                  BuildContext context,
                  int index,
                ) {
                  String text = mydata[index]['text'];
                  String source = mydata[index]['source'];
                  String darga = mydata[index]['darga'];
                  String sharetxt = text + "\n" + darga;

                  return new Column(children: <Widget>[
                    new Card(
                        elevation: 10,
                        margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)),
                        //shadowColor: Theme.of(context).primaryColor,
                        child: Column(
                          children: <Widget>[
                            new Card(
                              color: Theme.of(context).primaryColor,
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
                                    //
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 0, 15, 0),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: () {
                                          Share.share(sharetxt);
                                        },
                                        child: CircleAvatar(
                                          backgroundColor:
                                              Theme.of(context).cardColor,
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
                                                  'أحاديث لا تصح' +
                                                  '<br>' +
                                                  'البطاقة رقم: ' +
                                                  '$cardnum' +
                                                  '<br>' +
                                                  'النص: ' +
                                                  '$text' +
                                                  '<br>' +
                                                  'والصواب:' +
                                                  '<br>');
                                        },
                                        child: CircleAvatar(
                                          backgroundColor:
                                              Theme.of(context).cardColor,
                                          child: Icon(Icons.warning),
                                        ),
                                      ),
                                    ),
                                    //
                                  ],
                                ),
                              ),
                            ),

                            //
                            InkWell(
                              borderRadius: BorderRadius.circular(20),
                              highlightColor: Colors.transparent,
                              splashColor: Theme.of(context).accentColor,
                              onLongPress: () {
                                final snackBar = SnackBar(
                                  content: Text(
                                    mydata[index]['source'],
                                    textAlign: TextAlign.center,
                                    softWrap: true,
                                  ),
                                  action: SnackBarAction(
                                      label: 'نسخ',
                                      onPressed: () {
                                        // Some code to undo the change.
                                        Share.share(source);
                                      }),
                                );

                                // Find the Scaffold in the widget tree and use
                                // it to show a SnackBar.
                                Scaffold.of(context).showSnackBar(snackBar);
                              },
                              onTap: () {},
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(10, 15, 10, 10),
                                child: new Column(
                                  textDirection: TextDirection.rtl,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.all(7),
                                      child: new Text(
                                        text,
                                        textAlign: TextAlign.center,
                                        softWrap: true,
                                        textDirection: TextDirection.rtl,
                                        style: TextStyle(
                                            fontSize: 10 * fontSize,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    new Text(""),
                                    new Text(
                                      mydata[index]['darga'],
                                      textAlign: TextAlign.center,
                                      textDirection: TextDirection.rtl,
                                      softWrap: true,
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 10),
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )),
                  ]);
                },
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: new CupertinoSlider(
                  value: fontSize,
                  thumbColor: Theme.of(context).accentColor,
                  activeColor: Theme.of(context).accentColor,
                  onChanged: (double s) {
                    setState(() {
                      fontSize = s;
                    });
                  },
                  divisions: 20,
                  min: 1.0,
                  max: 5.0,
                ),
              ),
              Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                          icon: Icon(
                              Theme.of(context).brightness == Brightness.dark
                                  ? Icons.wb_sunny
                                  : Icons.cloud),
                          onPressed: () {
                            DynamicTheme.of(context).setBrightness(
                                Theme.of(context).brightness == Brightness.dark
                                    ? Brightness.light
                                    : Brightness.dark);
                          }),
                      IconButton(
                          icon: Icon(Icons.settings),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Settings()),
                            );
                          }),
                    ],
                  ))
            ],
          ),
        ),
      ),
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
