import 'package:flutter/material.dart';
import 'package:hisnelmoslem/core/values/constant.dart';

import 'const_colors.dart';

class Themes {
  ///
  static ThemeData get light {
    mainColor = const Color.fromARGB(255, 105, 187, 253);
    scrollEndColor = black26;

    return ThemeData.light().copyWith(
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
  }

  ///
  static ThemeData get dark {
    mainColor = const Color.fromARGB(255, 105, 187, 253);
    scrollEndColor = black26;
    return ThemeData.dark().copyWith(
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
  }

  ///
  static ThemeData get trueBlack {
    mainColor = const Color.fromARGB(255, 105, 187, 253);
    scrollEndColor = black26;
    return ThemeData.dark().copyWith(
      primaryColor: trueBlackColor,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        color: trueBlackColor,
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
        color: trueBlackColor,
      ),
      dialogTheme: const DialogTheme(
        backgroundColor: trueBlackColor,
      ),
      snackBarTheme: const SnackBarThemeData(
          backgroundColor: trueBlackColor,
          contentTextStyle: TextStyle(color: lightColor)),
      cardColor: trueBlackColor.withAlpha(220),
      scaffoldBackgroundColor: trueBlackColor,
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: lightColor,
      ),
    );
  }

  ///
  static ThemeData get darkDefault {
    mainColor = const Color.fromARGB(255, 105, 187, 253);
    scrollEndColor = black26;

    return ThemeData.dark();
  }

  ///
  static ThemeData get yellowTheme {
    mainColor = yellowColorSecondary;
    scrollEndColor = yellowColorSecondary;
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: yellowColorPrimary,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: yellowColorPrimary,
        iconTheme: const IconThemeData(
          color: yellowColorSecondary,
        ),
        toolbarTextStyle: const TextStyle().copyWith(
          color: yellowColorSecondary,
        ),
        titleTextStyle: const TextStyle().copyWith(
          color: yellowColorSecondary,
          fontSize: 20,
          fontFamily: "Uthmanic",
          fontWeight: FontWeight.bold,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: yellowColorPrimary,
        foregroundColor: yellowColorSecondary,
      ),
      bottomAppBarTheme: const BottomAppBarTheme().copyWith(
        elevation: 0,
        color: yellowColorPrimary,
      ),
      bottomAppBarColor: yellowColorPrimary,
      tabBarTheme: const TabBarTheme().copyWith(
        labelColor: yellowColorSecondary,
      ),
      iconTheme: const IconThemeData().copyWith(color: yellowColorSecondary),
      splashColor: yellowColorSecondary,
      bottomSheetTheme: const BottomSheetThemeData().copyWith(
        backgroundColor: yellowColorPrimary,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData().copyWith(
        backgroundColor: yellowColorPrimary,
      ),
      cardTheme: const CardTheme(
        elevation: 5,
        color: yellowColorPrimary,
      ),
      primaryColor: yellowColorSecondary,
      listTileTheme: const ListTileThemeData(
        textColor: yellowColorSecondary,
        iconColor: yellowColorSecondary,
      ),
      textTheme: const TextTheme().copyWith(
        bodyMedium: const TextStyle(
          color: yellowColorSecondary,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: yellowColorPrimary,
        contentTextStyle: TextStyle(color: yellowColorSecondary),
        actionTextColor: yellowColorSecondary,
      ),
    );
  }
}
