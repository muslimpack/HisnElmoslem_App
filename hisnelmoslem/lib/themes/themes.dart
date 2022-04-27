import 'package:flutter/material.dart';

import 'const_colors.dart';

class Themes {
  ///
  static final light = ThemeData.light().copyWith(
    primaryColor: lightColor,
    splashColor: Colors.blue,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      color: lightColor,
      iconTheme: IconThemeData(
        color: darkColor,
      ),
      actionsIconTheme: IconThemeData(color: darkColor),
      titleTextStyle: TextStyle(
        color: darkColor,
        fontSize: 20,
        fontFamily: "Uthmanic",
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomAppBarTheme: const BottomAppBarTheme(
      elevation: 0,
      color: lightColor,
    ),
    dialogTheme: const DialogTheme(
      backgroundColor: lightColor,
    ),
    tabBarTheme: const TabBarTheme(
      unselectedLabelColor: darkColor,
      labelColor: darkColor,
    ),
    cardColor: lightColor.withAlpha(220),
    snackBarTheme: const SnackBarThemeData(
        backgroundColor: lightColor,
        contentTextStyle: TextStyle(color: darkColor)),
    scaffoldBackgroundColor: lightColor,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: darkColor, splashColor: Colors.blue),
  );

  ///
  static final dark = ThemeData.dark().copyWith(
    primaryColor: darkColor,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      color: darkColor,
      iconTheme: IconThemeData(
        color: lightColor,
      ),
      actionsIconTheme: IconThemeData(color: lightColor),
      titleTextStyle: TextStyle(
        color: lightColor,
        fontSize: 20,
        fontFamily: "Uthmanic",
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomAppBarTheme: const BottomAppBarTheme(
      elevation: 0,
      color: darkColor,
    ),
    dialogTheme: const DialogTheme(
      backgroundColor: darkColor,
    ),
    snackBarTheme: const SnackBarThemeData(
        backgroundColor: darkColor,
        contentTextStyle: TextStyle(color: lightColor)),
    cardColor: darkColor.withAlpha(220),
    scaffoldBackgroundColor: darkColor,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: lightColor,
    ),
  );

  ///
  static final darkDefault = ThemeData.dark();
}
