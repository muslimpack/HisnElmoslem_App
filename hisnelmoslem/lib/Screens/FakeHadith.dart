import 'package:flutter/material.dart';
import 'package:hisnelmoslem/Shared/Cards/HadithCard.dart';
import 'package:hisnelmoslem/Utils/fake_hadith_database_helper.dart';
import 'package:hisnelmoslem/models/AzkarDb/DbFakeHaith.dart';
import 'package:provider/provider.dart';
import 'package:hisnelmoslem/Providers/AppSettings.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class FakeHadith extends StatefulWidget {
  @override
  _FakeHadithState createState() => _FakeHadithState();
}

class _FakeHadithState extends State<FakeHadith> {
  final _fakeHadithScaffoldKey = GlobalKey<ScaffoldState>();
  List<DbFakeHaith> fakeHadithList = <DbFakeHaith>[];

  bool isLoading = false;

  getReady() async {
    await fakeHadithDatabaseHelper
        .getAllFakeHadiths()
        .then((value) => fakeHadithList = value);

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getReady();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appSettings = Provider.of<AppSettingsNotifier>(context);
    return Scaffold(
      key: _fakeHadithScaffoldKey,
      appBar: AppBar(
        elevation: 0,
        title: Text("أحاديث منتشرة لا تصح"),
        //backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: ScrollConfiguration(
        behavior: ScrollBehavior(),
        child: GlowingOverscrollIndicator(
          axisDirection: AxisDirection.down,
          color: Colors.black26,
          child: ListView.builder(
            physics: ClampingScrollPhysics(),
            padding: EdgeInsets.only(top: 10),
            itemBuilder: (context, index) {
              return HadithCard(
                fakeHaith: fakeHadithList[index],
                scaffoldKey: _fakeHadithScaffoldKey,
              );
            },
            itemCount: fakeHadithList.length,
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
