import 'dart:convert';
import 'package:hisnelmoslem/Screen/azakar_page.dart';
import 'package:hisnelmoslem/model/zikr.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class BookmarkPage extends StatefulWidget {
  BookmarkPage({Key key}) : super(key: key);

  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  //*
  List<Zikr> _zikr = List<Zikr>();
  List<Zikr> _zikrForDisplay = List<Zikr>();

  Future<List<Zikr>> fetchAzkar() async {
    String data = await rootBundle.loadString('json/azkar.json');

    var azkar = List<Zikr>();

    var azkarJson = json.decode(data);
    for (var azkarJson in azkarJson) {
      azkar.add(Zikr.fromJson(azkarJson));
    }

    return azkar;
  }

  @override
  void initState() {
    super.initState();
    fetchAzkar();
    fetchAzkar().then((value) {
      setState(() {
        _zikr.addAll(value);
        _zikrForDisplay = _zikr;
        //* return bookmarked only //////////
        _zikrForDisplay = _zikr.where((zikr) {
          var zikrTitle = zikr.bookmark;
          return zikrTitle.contains("1");
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        elevation: 20,
        centerTitle: true,
        title: new Text(
          "المفضلة",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25),
        ),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return fehrsItems(index);
        },
        itemCount: _zikrForDisplay.length,
      ),
    );
  }

  fehrsItems(index) {
    return new Card(
      elevation: 10,
      margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: InkWell(
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        splashColor: Theme.of(context).accentColor,
        onLongPress: () {},
        onTap: () {
          Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) =>
                    new AzkarPage(_zikrForDisplay[index])),
          );
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
                _zikrForDisplay[index].title,
                textAlign: TextAlign.center,
                softWrap: true,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
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
                          backgroundColor: Theme.of(context).cardColor,
                          child: Text(
                            _zikrForDisplay[index].count,
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      new Container(
                        margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                        child: CircleAvatar(
                            backgroundColor: Theme.of(context).cardColor,
                            child: _zikrForDisplay[index].bookmark == "0"
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
  }
}
