import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hisnelmoslem/Providers/AppSettings.dart';
import 'package:hisnelmoslem/Utils/alarm_database_helper.dart';
import 'package:provider/provider.dart';
import 'AppManager/NotificationManager.dart';
import 'Screens/Dashboard.dart';
import 'Utils/azkar_database_helper.dart';

void main() async{
  //Make sure all stuff are initialized
  WidgetsFlutterBinding.ensureInitialized();

  //U Doesn't open app notification
  localNotifyManager.appOpenNotification();

  //Initialize Databases
  await azkarDatabaseHelper.initDb();
  await alarmDatabaseHelper.initDb();

  //Set All Alarm in database to confirm it
  // await alarmManager.checkAllAlarms();

  // Make Phone StatusBar Transparent
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent));

  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoading = false;
  bool isSearching = false;
  String? searchTxt;
  late TabController tabController;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });

    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);

    // //Manage Notification feedback
    // localNotifyManager.setOnNotificationReceive(onNotificationReceive);
    // localNotifyManager.setOnNotificationClick(onNotificationClick);

    super.initState();
  }

  //
  // onNotificationReceive(ReceiveNotification notification) {
  // }
  //
  // onNotificationClick(String payload) {
  //   print('payload = $payload');
  //   if(payload == "الكهف")
  //     {
  //       transitionAnimation.fromBottom2Top(
  //           context: context,
  //           goToPage: QuranReadPage());
  //     }
  //   else if(payload == "555" || payload == "777")
  //     {
  //
  //     }
  //   else
  //     {
  //       int pageIndex = int.parse(payload);
  //       print('pageIndex = $pageIndex');
  //       if(pageIndex != null)
  //         {
  //           print('Will open = $pageIndex');
  //           print(pageIndex.toString());
  //           transitionAnimation.fromBottom2Top(
  //               context: context, goToPage: AzkarReadPage(index:pageIndex));
  //         }
  //
  //     }
  //   // switch (payload) {
  //   //   case "الكهف":
  //   //     transitionAnimation.fromBottom2Top(
  //   //         context: context,
  //   //         goToPage: QuranReadPage());
  //   //     break;
  //   //   case "أذكار الصباح":
  //   //     transitionAnimation.fromBottom2Top(
  //   //         context: context, goToPage: AzkarReadPage(index: 28));
  //   //     break;
  //   //   case "أذكار المساء":
  //   //     transitionAnimation.fromBottom2Top(
  //   //         context: context, goToPage: AzkarReadPage(index: 29));
  //   //     break;
  //   //   case "أذكار النوم":
  //   //     transitionAnimation.fromBottom2Top(
  //   //         context: context, goToPage: AzkarReadPage(index: 30));
  //   //     break;
  //   //   case "أذكار الاستيقاظ":
  //   //     transitionAnimation.fromBottom2Top(
  //   //         context: context, goToPage: AzkarReadPage(index: 2));
  //   //     break;
  //   // }
  // }

  @override
  Widget build(BuildContext context) {
    // Make Phone StatusBar Transparent
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    return ListenableProvider(
         create: (context) => AppSettingsNotifier(),

      child: MaterialApp(
        // Make UI RTL
        localizationsDelegates: [
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('ar', 'AE')
        ],
        debugShowCheckedModeBanner: false,
        title: 'حصن المسلم',
        theme: ThemeData.dark( ),
        home: AzkarDashboard(),
      ),
    );
  }
}
