import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hisnelmoslem/Shared/Widgets/Loading.dart';
import 'package:hisnelmoslem/Shared/constant.dart';
import 'package:hisnelmoslem/models/json/Quran.dart';

class QuranReadPage extends StatefulWidget {
  @override
  _QuranReadPageState createState() => _QuranReadPageState();
}

class _QuranReadPageState extends State<QuranReadPage> {
  static const _volumeBtnChannel = MethodChannel("volume_button_channel");
  //
  final _quranReadPageScaffoldKey = GlobalKey<ScaffoldState>();
  PageController? _pageController;
  int currentPage = 0;

  List<Quran> _quran = <Quran>[];
  List<Quran> _quranDisplay = <Quran>[];
  bool isLoading = true;

  Future<List<Quran>> fetchAzkar() async {
    setState(() {
      isLoading = true;
    });
    String data = await rootBundle.loadString('assets/json/quran.json');

    var quran = <Quran>[];

    var quranJson = json.decode(data);
    for (var quranJson in quranJson) {
      quran.add(Quran.fromJson(quranJson));
    }

    return quran;
  }

  @override
  void initState() {
    preparePages();
    //
    _pageController = PageController(initialPage: 0);
    super.initState();
    //
    _volumeBtnChannel.setMethodCallHandler((call) {
      if (call.method == "volumeBtnPressed") {
        if (call.arguments == "VOLUME_DOWN_UP") {
          _pageController!.nextPage(
            duration: new Duration(milliseconds: 500),
            curve: Curves.easeIn,
          );
        }
        if (call.arguments == "VOLUME_UP_UP") {
          _pageController!.previousPage(
            duration: new Duration(milliseconds: 500),
            curve: Curves.easeIn,
          );
        }
      }

      return Future.value(null);
    });
  }

  preparePages() async {
    await fetchAzkar().then((value) {
      setState(() {
        _quran.addAll(value);
        _quranDisplay = _quran;
      });
    });
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _pageController!.dispose();
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
            // backgroundColor: Colors.yellow.withOpacity(.3),
            key: _quranReadPageScaffoldKey,
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              title: Text(_quranDisplay[0].surha,
                  style: TextStyle(fontFamily: "Uthmanic")),
              actions: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
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
                    return Stack(
                      children: [
                        BetweenPageEffect(index: index + 1),
                        PageSideEffect(index: index + 1),
                        Center(
                          child: ColorFiltered(
                              colorFilter: greyScale,
                              child: ColorFiltered(
                                  colorFilter: invert,
                                  child: Image.asset(
                                    _quranDisplay[0].pages[index].toString(),
                                    fit: BoxFit.fitWidth,
                                  ))),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
  }
}

class BetweenPageEffect extends StatelessWidget {
  final int index;

  const BetweenPageEffect({
    Key? key,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: index.isOdd ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: 50,
        decoration: new BoxDecoration(
            gradient: new LinearGradient(
          begin: index.isEven ? Alignment.centerRight : Alignment.centerLeft,
          end: index.isEven ? Alignment.centerLeft : Alignment.centerRight,
          colors: [
            // Color.fromARGB(10, 225, 255, 255),
            // Theme.of(context).primaryColor.withAlpha(90),
            Colors.black.withOpacity(.05),
            Colors.black.withOpacity(.1),
          ],
        )),
      ),
    );
  }
}

class PageSideEffect extends StatelessWidget {
  final int index;

  const PageSideEffect({
    Key? key,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      //left: index.isEven ? 0 : 20,
      //right: index.isEven ? 20 : 0,
      alignment: index.isEven ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: 5,
        height: 5000,
        decoration: new BoxDecoration(
            gradient: new LinearGradient(
          begin: index.isEven ? Alignment.centerRight : Alignment.centerLeft,
          end: index.isEven ? Alignment.centerLeft : Alignment.centerRight,
          colors: [
            Color.fromARGB(255, 225, 255, 255),
            Colors.black.withAlpha(200),
          ],
        )),
      ),
    );
  }
}
