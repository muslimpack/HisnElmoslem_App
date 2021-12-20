import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hisnelmoslem/Widgets/Loading.dart';
import 'package:hisnelmoslem/models/Quran.dart';

class QuranReadPage extends StatefulWidget {
  @override
  _QuranReadPageState createState() => _QuranReadPageState();
}

class _QuranReadPageState extends State<QuranReadPage> {
  final _quranReadPageScaffoldKey = GlobalKey<ScaffoldState>();
  PageController _pageController;
  int currentPage = 0;

  List<Quran> _quran = List<Quran>();
  List<Quran> _quranDisplay = List<Quran>();
  bool isLoading = false;

  Future<List<Quran>> fetchAzkar() async {
    setState(() {
      isLoading = true;
    });
    String data = await rootBundle.loadString('assets/json/quran.json');

    var quran = List<Quran>();

    var quranJson = json.decode(data);
    for (var quranJson in quranJson) {
      quran.add(Quran.fromJson(quranJson));
    }

    return quran;
  }

  @override
  void initState() {
    fetchAzkar();
    fetchAzkar().then((value) {
      setState(() {
        _quran.addAll(value);
        _quranDisplay = _quran;
      });
    });
    setState(() {
      isLoading = false;
    });
    _pageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  _onPageViewChange(int page) {
    //  currentPage = page;
    setState(() {
      currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    int page = 293;
    return isLoading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.white,
            key: _quranReadPageScaffoldKey,
            appBar: AppBar(
              title: Text(_quranDisplay[0].surha),
              actions: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: CircleAvatar(
                    child: Text('${page + currentPage}'),
                  ),
                )
              ],
            ),
            body: ScrollConfiguration(
              behavior: ScrollBehavior(),
              child: GlowingOverscrollIndicator(
                axisDirection: AxisDirection.left,
                color: Colors.black26,
                child: PageView.builder(
                  onPageChanged: _onPageViewChange,
                  controller: _pageController,
                  itemCount: _quranDisplay[0].pages.length,
                  itemBuilder: (context, index) {
                    return Image.asset(
                      _quranDisplay[0].pages[index].toString(),
                      fit: BoxFit.fitWidth,
                    );
                  },
                ),
              ),
            ),
          );
  }
}
