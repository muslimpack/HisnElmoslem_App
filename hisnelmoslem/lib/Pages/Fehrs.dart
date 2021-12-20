import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hisnelmoslem/Cards/zikrCard.dart';
import 'package:hisnelmoslem/Widgets/Loading.dart';
import 'package:hisnelmoslem/models/Zikr.dart';

class Fehrs extends StatefulWidget {
  final bool isSearching;
  final String searchTxt;

  const Fehrs({Key key, this.isSearching, this.searchTxt}) : super(key: key);

  @override
  _FehrsState createState() => _FehrsState();
}

class _FehrsState extends State<Fehrs> {
  List<Zikr> _zikr = List<Zikr>();
  List<Zikr> _zikrForDisplay = List<Zikr>();
  bool isLoading = false;

  Future<List<Zikr>> fetchAzkar() async {
    setState(() {
      isLoading = true;
    });
    String data = await rootBundle.loadString('assets/json/azkar.json');

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
    setState(() {
      isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {

    if(widget.isSearching){
      if(widget.searchTxt.isEmpty || widget.searchTxt == null || widget.searchTxt == ""){
        _zikrForDisplay = _zikr.where((zikr) {
          var zikrTitle = zikr.title;
          return zikrTitle.contains("");
        }).toList();
      }
      else{
        setState(() {
          _zikrForDisplay = _zikr.where((zikr) {
            var zikrTitle = zikr.title.replaceAll(
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
            return zikrTitle.contains(widget.searchTxt);
          }).toList();
        });
      }


    }else{
      _zikrForDisplay = _zikr.where((zikr) {
        var zikrTitle = zikr.title;
        return zikrTitle.contains("");
      }).toList();
    }
    return  isLoading? Loading(): Scaffold(
      body: ListView.builder(
        padding: EdgeInsets.only(top: 10),
        itemBuilder: (context, index) {
          return ZikrCard(index: index, zikrList: _zikrForDisplay);
        },
        itemCount: _zikrForDisplay.length,
      ),
   );
  }
}
