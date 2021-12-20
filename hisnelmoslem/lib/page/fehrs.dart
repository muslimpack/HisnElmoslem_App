import 'dart:convert';
import 'package:hisnelmoslem/Screen/azkar_page_card.dart';
import 'package:hisnelmoslem/Screen/azkar_page_page.dart';
import 'package:hisnelmoslem/model/zikr.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hisnelmoslem/provider/azkar_mode.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class Hisn extends StatefulWidget {
  Hisn({Key key}) : super(key: key);

  @override
  _HisnState createState() => _HisnState();
}

class _HisnState extends State<Hisn> {
  bool isSearching = false;
  String searchtxt;

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
      });
    });
  }

  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final azkarMode = Provider.of<AzkarMode>(context);
    return new Scaffold(
      appBar: new AppBar(
        elevation: 20,
        centerTitle: true,
        title: new Text(
          "الفهرس",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25),
        ),
        actions: [
          isSearching
              ? Container()
              : IconButton(
                  icon: Icon(FontAwesomeIcons.search),
                  onPressed: () {
                    setState(() {
                      isSearching = !isSearching;
                    });
                  })
        ],
        bottom: isSearching
            ? PreferredSize(
                child: TextFormField(
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    decorationColor: Color(0XFFFFCC00),
                  ),
                  textAlign: TextAlign.center,
                  controller: searchController,
                  autofocus: true,
                  onChanged: (searchtxt) {
                    this.searchtxt = searchtxt;
                    setState(() {
                      _zikrForDisplay = _zikr.where((zikr) {
                        var zikrTitle = zikr.title.toLowerCase().replaceAll(
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
                        return zikrTitle.contains(searchController.text);
                      }).toList();
                    });
                  },
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    labelStyle:
                        TextStyle(color: Theme.of(context).primaryColor),
                    hintStyle: TextStyle(color: Theme.of(context).primaryColor),
                    hintText: "....البحث",
                    contentPadding: EdgeInsets.only(
                        left: 15, bottom: 11, top: 11, right: 15),
                    suffixIcon: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            isSearching = !isSearching;
                            //* set controller to empty
                            searchController.clear();
                            //* return all
                            _zikrForDisplay = _zikr.where((zikr) {
                              var zikrTitle = zikr.title;
                              return zikrTitle.contains("");
                            }).toList();
                          });
                        }),
                    prefixIcon: Icon(FontAwesomeIcons.search),
                    filled: true,
                  ),
                ),
                preferredSize: Size(50, 50))
            : PreferredSize(child: Container(), preferredSize: Size(0, 0)),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return fehrsItems(index, azkarMode);
        },
        itemCount: _zikrForDisplay.length,
      ),
    );
  }

  fehrsItems(index, AzkarMode azkarMode) {
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
          azkarMode.getAzkarMode() == "Card"
              ? Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (BuildContext context) =>
                          new AzkarPage(_zikrForDisplay[index])),
                )
              : Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (BuildContext context) =>
                          new AzkarPagePage(_zikrForDisplay[index])),
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
