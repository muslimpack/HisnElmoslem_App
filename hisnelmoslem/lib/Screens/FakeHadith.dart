import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hisnelmoslem/Shared/Cards/HadithCard.dart';
import 'package:hisnelmoslem/models/json/Hadith.dart';
import 'package:provider/provider.dart';
import 'package:hisnelmoslem/Providers/AppSettings.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class FakeHadith extends StatefulWidget {
  @override
  _FakeHadithState createState() => _FakeHadithState();
}

class _FakeHadithState extends State<FakeHadith> {
  final _fakeHadithScaffoldKey = GlobalKey<ScaffoldState>();
  List<Hadith> fakeHadithList =  <Hadith>[];
  List<Hadith> fakeHadithListForDispaly =  <Hadith>[];
  bool isLoading = false;

  Future<List<Hadith>> fetchHadith() async {
    setState(() {
      isLoading = true;
    });
    String data = await rootBundle.loadString('assets/json/fakehadith.json');

    var hadith = <Hadith>[];

    var azkarJson = json.decode(data);
    for (var azkarJson in azkarJson) {
      hadith.add(Hadith.fromJson(azkarJson));
    }
    return hadith;
  }

  @override
  void initState() {
    super.initState();
    fetchHadith();
    fetchHadith().then((value) {
      setState(() {
        fakeHadithList.addAll(value);
        fakeHadithListForDispaly = fakeHadithList;
      });
    });
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appSettings = Provider.of<AppSettingsNotifier>(context);
    return Scaffold(
      key:_fakeHadithScaffoldKey ,
      appBar: AppBar(
        elevation: 0,
        title: Text("أحاديث منتشرة لا تصح"),
        //backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body:   ScrollConfiguration(
        behavior: ScrollBehavior(),

        child: GlowingOverscrollIndicator(
            axisDirection: AxisDirection.down,
            color: Colors.black26,

          child: ListView.builder(
            physics: ClampingScrollPhysics(),
            padding: EdgeInsets.only(top: 10),
            itemBuilder: (context, index) {
              return HadithCard(
                index: index,
                hadith: fakeHadithListForDispaly,
                scaffoldKey: _fakeHadithScaffoldKey,
              );
            },
            itemCount: fakeHadithListForDispaly.length,
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        //elevation: 20,
        color: Theme.of(context).primaryColor,
        child: Container(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  flex: 1,
                  child: IconButton(
                      icon: Icon(MdiIcons.formatFontSizeIncrease),
                      onPressed: () {
                        setState(() {
                          appSettings
                              .setfontSize(appSettings.getfontSize() + 0.3);
                        });
                      })),
              Expanded(
                  flex: 1,
                  child: IconButton(
                      icon: Icon(MdiIcons.formatFontSizeDecrease),
                      onPressed: () {
                        setState(() {
                          appSettings
                              .setfontSize(appSettings.getfontSize() - 0.3);
                        });
                      })),

              /*   */
            ],
          ),
        ),
      ),
    );
  }
}


