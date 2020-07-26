import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:open_appstore/open_appstore.dart';

class RecApp extends StatefulWidget {
  RecApp({Key key}) : super(key: key);

  @override
  _RecAppState createState() => _RecAppState();
}

class _RecAppState extends State<RecApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 20,
          centerTitle: true,
          title: new Text(
            "تطبيقات نوصي بها",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.all(10),
          children: <Widget>[
            //
            Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(40))),
                margin: EdgeInsets.only(bottom: 0, top: 0),
                elevation: 20,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: ListTile(
                        trailing: Image.asset(
                          'assets/app_quran.png',
                        ),
                        title: Text(
                          'قرآن أندرويد',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 30),
                        ),
                      ),
                    ),
                    Card(
                      color: Theme.of(context).primaryColor,
                      margin: EdgeInsets.only(bottom: 0, top: 0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40))),
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
                                  OpenAppstore.launch(
                                      androidAppId:
                                          "com.quran.labs.androidquran");
                                },
                                child: CircleAvatar(
                                  backgroundColor: Theme.of(context).cardColor,
                                  child: Icon(FontAwesomeIcons.android),
                                ),
                              ),
                            ),

                            //
                            Container(
                              margin: EdgeInsets.fromLTRB(15, 0, 0, 0),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  OpenAppstore.launch(iOSAppId: "1118663303");
                                },
                                child: CircleAvatar(
                                  backgroundColor: Theme.of(context).cardColor,
                                  child: Icon(FontAwesomeIcons.appStoreIos),
                                ),
                              ),
                            ),
                            //
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
            //
            SizedBox(
              height: 10,
            ),
            //
            Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(40))),
                margin: EdgeInsets.only(bottom: 0, top: 0),
                elevation: 20,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: ListTile(
                        trailing: Image.asset(
                          'assets/app_game3.png',
                        ),
                        title: Text(
                          'جامع الكتب التسعة',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 30),
                        ),
                      ),
                    ),
                    Card(
                      color: Theme.of(context).primaryColor,
                      margin: EdgeInsets.only(bottom: 0, top: 0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40))),
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
                                  OpenAppstore.launch(
                                      androidAppId: "com.arabiait.sunna");
                                },
                                child: CircleAvatar(
                                  backgroundColor: Theme.of(context).cardColor,
                                  child: Icon(FontAwesomeIcons.android),
                                ),
                              ),
                            ),

                            //
                            Container(
                              margin: EdgeInsets.fromLTRB(15, 0, 0, 0),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  OpenAppstore.launch(iOSAppId: "1149785262");
                                },
                                child: CircleAvatar(
                                  backgroundColor: Theme.of(context).cardColor,
                                  child: Icon(FontAwesomeIcons.appStoreIos),
                                ),
                              ),
                            ),
                            //
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
            //
            SizedBox(
              height: 10,
            ),
            //
            Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(40))),
                margin: EdgeInsets.only(bottom: 0, top: 0),
                elevation: 20,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: ListTile(
                        trailing: Image.asset(
                          'assets/app_dorar.png',
                        ),
                        title: Text(
                          'الموسوعة الحديثية',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 25),
                        ),
                      ),
                    ),
                    Card(
                      color: Theme.of(context).primaryColor,
                      margin: EdgeInsets.only(bottom: 0, top: 0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40))),
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
                                  OpenAppstore.launch(
                                      androidAppId: "com.zad.hadith");
                                },
                                child: CircleAvatar(
                                  backgroundColor: Theme.of(context).cardColor,
                                  child: Icon(FontAwesomeIcons.android),
                                ),
                              ),
                            ),

                            //
                            Container(
                              margin: EdgeInsets.fromLTRB(15, 0, 0, 0),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  OpenAppstore.launch(iOSAppId: "599410474");
                                },
                                child: CircleAvatar(
                                  backgroundColor: Theme.of(context).cardColor,
                                  child: Icon(FontAwesomeIcons.appStoreIos),
                                ),
                              ),
                            ),
                            //
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
            //
            SizedBox(
              height: 10,
            ),
            //
            Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(40))),
                margin: EdgeInsets.only(bottom: 0, top: 0),
                elevation: 20,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: ListTile(
                        trailing: Image.asset(
                          'assets/app_paqeyat.png',
                        ),
                        title: Text(
                          'الباقيات',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 30),
                        ),
                      ),
                    ),
                    Card(
                      color: Theme.of(context).primaryColor,
                      margin: EdgeInsets.only(bottom: 0, top: 0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40))),
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
                                  OpenAppstore.launch(
                                      androidAppId: "com.arabiait.azkar");
                                },
                                child: CircleAvatar(
                                  backgroundColor: Theme.of(context).cardColor,
                                  child: Icon(FontAwesomeIcons.android),
                                ),
                              ),
                            ),

                            //
                            Container(
                              margin: EdgeInsets.fromLTRB(15, 0, 0, 0),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  OpenAppstore.launch(iOSAppId: "1041788729");
                                },
                                child: CircleAvatar(
                                  backgroundColor: Theme.of(context).cardColor,
                                  child: Icon(FontAwesomeIcons.appStoreIos),
                                ),
                              ),
                            ),
                            //
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
            //
            SizedBox(
              height: 10,
            ),
            //
            Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(40))),
                margin: EdgeInsets.only(bottom: 0, top: 0),
                elevation: 20,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: ListTile(
                        trailing: Image.asset(
                          'assets/app_azthan.png',
                        ),
                        title: Text(
                          'أوقات الصلاة',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 25),
                        ),
                      ),
                    ),
                    Card(
                      color: Theme.of(context).primaryColor,
                      margin: EdgeInsets.only(bottom: 0, top: 0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40))),
                      elevation: 5,
                      child: Container(
                        width: 200,
                        padding: EdgeInsets.all(7),
                        child: Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 15, 0),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              OpenAppstore.launch(
                                  androidAppId: "com.athanotify");
                            },
                            child: CircleAvatar(
                              backgroundColor: Theme.of(context).cardColor,
                              child: Icon(FontAwesomeIcons.android),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          ],
        ));
  }
}
