import 'package:hisnelmoslem/page/fakehadith.dart';
import 'package:hisnelmoslem/page/recommended_app.dart';
import 'package:hisnelmoslem/page/settings.dart';
import 'package:hisnelmoslem/page/bookmark_page.dart';
import 'package:hisnelmoslem/page/fehrs.dart';
import 'package:hisnelmoslem/page/tally.dart';
import 'package:flutter/material.dart';
import 'package:hisnelmoslem/provider/azkar_mode.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  Dashboard({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final azkarMode = Provider.of<AzkarMode>(context);
    setState(() {
      azkarMode.getAzkarModeData();
    });

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[900]
          : Theme.of(context).primaryColor,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
              pinned: true,
              expandedHeight: 200.0,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text("حصن المسلم",
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              )),
          SliverGrid.count(
            crossAxisCount: 2,
            children: [
              gridCard(
                  "المفضلة", 'assets/bookmark.png', context, BookmarkPage()),

              gridCard("حصن المسلم", 'assets/hisn.png', context, Hisn()),

              gridCard("منتشر لا يصح", 'assets/fakehadith.png', context,
                  FakeHadith()),

              // DashboardCard("الإنجازات", 'assets/accomp.png', context, Accomplishment()),

              gridCard("السُبحة", 'assets/rosary.png', context, Tally()),

              gridCard("الإعدادات", 'assets/set.png', context, Settings()),

              gridCard("نوصي بها", 'assets/recommend.png', context, RecApp()),
            ],
          )
        ],
      ),
    );
  }
}

class Title extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 90),
        Text(
          "حصن المسلم",
          style: TextStyle(
              fontSize: 35, fontWeight: FontWeight.w900, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4),
        Text(
          "من أذكار الكتاب و السنة",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white60),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class GridDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      childAspectRatio: 1.0,
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
      crossAxisCount: 2,
      crossAxisSpacing: 18,
      mainAxisSpacing: 18,
      children: <Widget>[
        gridCard("المفضلة", 'assets/bookmark.png', context, BookmarkPage()),

        gridCard("حصن المسلم", 'assets/hisn.png', context, Hisn()),

        gridCard(
            "منتشر لا يصح", 'assets/fakehadith.png', context, FakeHadith()),

        // DashboardCard("الإنجازات", 'assets/accomp.png', context, Accomplishment()),

        gridCard("السُبحة", 'assets/rosary.png', context, Tally()),

        gridCard("الإعدادات", 'assets/set.png', context, Settings()),

        gridCard("نوصي بها", 'assets/recommend.png', context, RecApp()),
      ],
    );
  }
}

gridCard(String name, String imageAssets, context, Widget page) {
  return Padding(
    padding: const EdgeInsets.all(14),
    child: Card(
      elevation: 10,
      margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        highlightColor: Colors.transparent,
        splashColor: Theme.of(context).accentColor,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.transparent),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 14,
              ),
              Image.asset(
                imageAssets,
                width: 50,
              ),
              SizedBox(
                height: 14,
              ),
              Text(
                name,
                textAlign: TextAlign.center,
                softWrap: true,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
