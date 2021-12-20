import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hisnelmoslem/Cards/zikrCard.dart';
import 'package:hisnelmoslem/Widgets/Loading.dart';
import 'package:hisnelmoslem/models/Zikr.dart';

class Bookmarks extends StatefulWidget {
  @override
  _BookmarksState createState() => _BookmarksState();
}

class _BookmarksState extends State<Bookmarks> {
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
        //* return bookmarked only //////////
        _zikrForDisplay = _zikr.where((zikr) {
          var zikrTitle = zikr.bookmark;
          return zikrTitle.contains("1");
        }).toList();
      });
    });
    setState(() {
      isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return isLoading? Loading(): Scaffold(
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
