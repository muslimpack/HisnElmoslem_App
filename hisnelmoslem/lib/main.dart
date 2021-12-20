import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hisnelmoslem/Providers/AppSettings.dart';
import 'package:provider/provider.dart';
import 'Screens/Dashboard.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // Make Phone StatusBar Transparent
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    return Provider(
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
        home: DashboardScreen(),
      ),
    );
  }
}
