import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hisnelmoslem/Pages/Bookmarks.dart';
import 'package:hisnelmoslem/Pages/Fehrs.dart';
import 'package:hisnelmoslem/Providers/AppSettings.dart';
import 'package:hisnelmoslem/Screens/FakeHadith.dart';
import 'package:hisnelmoslem/Screens/QuranReadPage.dart';
import 'package:hisnelmoslem/Screens/Settings.dart';
import 'package:hisnelmoslem/Screens/Tally.dart';
import 'package:hisnelmoslem/Widgets/constant.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:hisnelmoslem/Notification/NotificationManager.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  String searchTxt;
  TabController tabController;
  PageController pageController;
  int currentIndex;
  var appSettings;

  @override
  void initState() {
    super.initState();
    localNotifyManager.setOnNotificationReceive(onNotificationReceive);
    localNotifyManager.setOnNotificationClick(onNotificationClick);
    tabController = new TabController(initialIndex: 0, length: 2, vsync: this);
    pageController = new PageController(initialPage: 0);
  }

  onNotificationReceive(ReceiveNotification notification) {
    //print('Notification Received: ${notification.id}');
  }

  onNotificationClick(String payload) {
    //print('Payload $payload');
    if (payload == "الكهف") {
      print('Payload $payload');
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return QuranReadPage();
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appSettings = Provider.of<AppSettingsNotifier>(context);
    setState(() {
      appSettings.getfontSizeData();
      appSettings.getTashkelStatusData();
      appSettings.getAzkarReadModeData();
      appSettings.getRemindersData();
    });
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: isSearching
              ? TextFormField(
                  style: TextStyle(decorationColor: MAINCOLOR),
                  textAlign: TextAlign.center,
                  controller: searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintText: "البحث",
                      contentPadding: EdgeInsets.only(
                          left: 15, bottom: 5, top: 5, right: 15),
                      prefix: IconButton(
                        icon: Icon(Icons.clear_all),
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            searchTxt = "";
                          });
                        },
                      )),
                  onChanged: (value) {
                    setState(() {
                      searchTxt = value;
                    });
                  },
                )
              : Text("حصن المسلم"),
          actions: [
            isSearching
                ? IconButton(
                    splashRadius: 20,
                    padding: EdgeInsets.all(0),
                    icon: Icon(Icons.exit_to_app_sharp),
                    onPressed: () {
                      setState(() {
                        isSearching = false;
                        searchController.clear();
                      });
                    })
                : IconButton(
                    splashRadius: 20,
                    padding: EdgeInsets.all(0),
                    icon: Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        isSearching = true;
                        searchTxt = "";
                      });
                    }),
            isSearching
                ? SizedBox()
                : IconButton(
                    splashRadius: 20,
                    padding: EdgeInsets.all(0),
                    icon: Icon(Icons.watch_outlined),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Tally();
                      }));
                    }),
            isSearching
                ? SizedBox()
                : IconButton(
                    splashRadius: 20,
                    padding: EdgeInsets.all(0),
                    icon: Icon(
                      MdiIcons.bookOpenPageVariant,
                    ),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return FakeHadith();
                      }));
                    }),
            IconButton(
                splashRadius: 20,
                padding: EdgeInsets.all(0),
                icon: Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return Settings();
                  }));
                }),
          ],
          bottom: TabBar(
            indicatorColor: Colors.blue.shade200,
            labelColor: Colors.blue.shade200,
            unselectedLabelColor: Colors.white,
            tabs: <Widget>[
              Tab(
                text: "الفهرس",
              ),
              Tab(
                text: "المفضلة",
              )
            ],
          ),
        ),
        body: ScrollConfiguration(
          behavior: ScrollBehavior(),
          child: GlowingOverscrollIndicator(
            axisDirection: AxisDirection.left,
            color: Colors.black26,
            child: TabBarView(
              physics: ClampingScrollPhysics(),
              children: [
                Fehrs(
                  isSearching: isSearching,
                  searchTxt: searchTxt,
                ),
                Bookmarks(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
