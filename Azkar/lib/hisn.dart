import 'dart:convert';
import 'package:Azkar/azakar_page.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class Hisn extends StatefulWidget {
  Hisn({Key key}) : super(key: key);

  @override
  _HisnState createState() => _HisnState();
}

class _HisnState extends State<Hisn> {
  List data;
  bool isSearching = false;
  String searchtxt;
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        elevation: 20,
        centerTitle: true,
        title: new Text(
          "الفهرس",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25),
        ),
      ),
      body: new Container(
        child: Center(
          child: new FutureBuilder(
            future:
                DefaultAssetBundle.of(context).loadString("json/azkar.json"),
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
                  int _counter = int.parse(mydata[index]['count']);
                  int _isBookmark = int.parse(mydata[index]['bookmark']);
                  bool isBookmark;
                  if (_isBookmark == 0) {
                    isBookmark = true;
                  } else if (_isBookmark == 1) {
                    isBookmark = false;
                  }

                  return new Card(
                    elevation: 10,
                    margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                    //shadowColor: Theme.of(context).primaryColor,
                    child: InkWell(
                      highlightColor: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      splashColor: Theme.of(context).accentColor,
                      onLongPress: () {},
                      onTap: () {
                        Navigator.push(
                            //
                            context,
                            new MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    new AzkarPage(mydata[index])));
                      },
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(10, 15, 10, 10),
                        child: new Column(
                          textDirection: TextDirection.rtl,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            new Text(
                              mydata[index]['title'],
                              textAlign: TextAlign.center,
                              softWrap: true,
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.w700),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Row(
                                  textDirection: TextDirection.rtl,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    new Container(
                                      margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                      child: CircleAvatar(
                                        backgroundColor:
                                            Theme.of(context).cardColor,
                                        child: Text(
                                          '$_counter',
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                    new Container(
                                      margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                      child: CircleAvatar(
                                          backgroundColor:
                                              Theme.of(context).cardColor,
                                          child: isBookmark
                                              ? Icon(
                                                  Icons.bookmark_border,
                                                )
                                              : Icon(
                                                  MdiIcons.bookmark,
                                                  color: Colors.green,
                                                )),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
