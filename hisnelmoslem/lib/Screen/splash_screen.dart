import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hisnelmoslem/Screen/onboarding.dart';
import 'package:hisnelmoslem/page/dashboard.dart';
import 'package:hisnelmoslem/provider/azkar_mode.dart';
import 'package:hisnelmoslem/provider/fontsize.dart';
import 'package:hisnelmoslem/provider/settings_provider.dart';
import 'package:hisnelmoslem/provider/theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  //* TO MAKE ONBOARDING OPEN ON THE FIRST TIME ONLY
  bool _seen = false;
  Future getSeenStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _seen = (prefs.getBool('seen') ?? false);
    return _seen;
  }

  Future setSeenStatus(bool seen) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('seen', seen);
  }

  //* THE SET TIMER TO NEXT SCREEN
  @override
  void initState() {
    super.initState();
    getSeenStatus();
    Timer(
      Duration(seconds: 0),
      () => Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) =>
              _seen ? Dashboard() : OnboardingScreen())),
    );
    setSeenStatus(true);
  }

  //* CALL APP SHAAREDPREFRENCECS
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context);
    final fontSize = Provider.of<FontSizeNotifier>(context);
    final userSettings = Provider.of<UserSettingsNotifier>(context);
    final azkarMode = Provider.of<AzkarMode>(context);

    setState(() {
      theme.getThemeData();
      fontSize.getfontSizeData();
      userSettings.getTashkelStatusData();
      azkarMode.getAzkarModeData();
    });

    return Scaffold(
      body: Container(),
    );
  }
}
