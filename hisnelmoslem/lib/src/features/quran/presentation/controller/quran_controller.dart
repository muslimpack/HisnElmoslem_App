import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/features/quran/data/models/quran_surah.dart';
import 'package:hisnelmoslem/src/features/quran/data/models/surah_name_enum.dart';

class QuranPageController extends GetxController {
  /* *************** Variables *************** */
  //
  final SurahNameEnum surahName;

  QuranPageController({required this.surahName});

  //
  static const _volumeBtnChannel = MethodChannel("volume_button_channel");

  //
  final quranReadPageScaffoldKey = GlobalKey<ScaffoldState>();
  PageController pageController = PageController();
  int currentPage = 0;

  //
  final List<QuranSurah> _quran = <QuranSurah>[];
  List<QuranSurah> quranDisplay = <QuranSurah>[];
  QuranSurah? quranRequiredSurah;

  //
  bool isLoading = true;

  //

  /* *************** Controller life cycle *************** */
  //
  @override
  Future<void> onInit() async {
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

      return Future.value();
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
    _volumeBtnChannel.setMethodCallHandler(null);
    //
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  /* *************** Functions *************** */

  ///
  void perpareRequiredPages(SurahNameEnum surahName) {
    if (surahName == SurahNameEnum.endofAliImran) {
      quranRequiredSurah = quranDisplay[0];
    } else if (surahName == SurahNameEnum.alKahf) {
      quranRequiredSurah = quranDisplay[1];
    } else if (surahName == SurahNameEnum.assajdah) {
      quranRequiredSurah = quranDisplay[2];
    } else if (surahName == SurahNameEnum.alMulk) {
      quranRequiredSurah = quranDisplay[3];
    }
  }

  ///
  Future<void> preparePages() async {
    await fetchAzkar().then((value) {
      _quran.addAll(value);
      quranDisplay = _quran;
    });
  }

  ///
  Future<List<QuranSurah>> fetchAzkar() async {
    final String data = await rootBundle.loadString('assets/json/quran.json');

    final quran = <QuranSurah>[];

    final quranJson = json.decode(data);

    if (quranJson is List) {
      for (final item in quranJson) {
        quran.add(QuranSurah.fromJson(item as Map<String, dynamic>));
      }
    }

    return quran;
  }

  ///
  void onPageViewChange(int page) {
    //  currentPage = page;
    currentPage = page;
    update();
  }

  void onDoubleTap() {
    // hide statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }
}
