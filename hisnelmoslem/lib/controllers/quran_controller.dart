import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/themes/theme_services.dart';

import '../models/json/quran.dart';

enum SurahNameEnum { alMulk, alKahf }

class QuranPageController extends GetxController {
  /* *************** Variables *************** */
  //
  final SurahNameEnum surahName;
  QuranPageController({required this.surahName});
  //
  static const _volumeBtnChannel = MethodChannel("volume_button_channel");
  //
  final quranReadPageScaffoldKey = GlobalKey<ScaffoldState>();
  PageController pageController = PageController(initialPage: 0);
  int currentPage = 0;
  //
  final List<Quran> _quran = <Quran>[];
  List<Quran> quranDisplay = <Quran>[];
  Quran? quranRequiredSurah;
  //
  bool isLoading = true;
  //

  /* *************** Controller life cycle *************** */
  //
  @override
  void onInit() async {
    super.onInit();
    // hide status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    //
    await preparePages();
    //
    perpareRequiredPages(surahName);

    _volumeBtnChannel.setMethodCallHandler((call) {
      if (call.method == "volumeBtnPressed") {
        if (call.arguments == "VOLUME_DOWN_UP") {
          pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeIn,
          );
        }
        if (call.arguments == "VOLUME_UP_UP") {
          pageController.previousPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeIn,
          );
        }
      }

      return Future.value(null);
    });

    isLoading = false;
    update();
  }

  @override
  void onClose() {
    super.onClose();
    //
    pageController.dispose();
    //
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  /* *************** Functions *************** */
  ///
  perpareRequiredPages(SurahNameEnum surahName) {
    if (surahName == SurahNameEnum.alKahf) {
      quranRequiredSurah = quranDisplay[0];
    } else if (surahName == SurahNameEnum.alMulk) {
      quranRequiredSurah = quranDisplay[1];
    }
  }

  ///
  preparePages() async {
    await fetchAzkar().then((value) {
      _quran.addAll(value);
      quranDisplay = _quran;
    });
  }

  ///
  Future<List<Quran>> fetchAzkar() async {
    String data = await rootBundle.loadString('assets/json/quran.json');

    var quran = <Quran>[];

    var quranJson = json.decode(data);
    for (var quranJson in quranJson) {
      quran.add(Quran.fromJson(quranJson));
    }

    return quran;
  }

  ///
  onPageViewChange(int page) {
    //  currentPage = page;
    currentPage = page;
    update();
  }

  void toggleTheme() {
    ThemeServices.changeThemeMode();
    update();
  }

  void onDoubleTap() {
    // hide statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }
}
