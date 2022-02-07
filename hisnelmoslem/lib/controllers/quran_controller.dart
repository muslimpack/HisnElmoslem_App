import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../models/json/Quran.dart';

class QuranPageController extends GetxController {
  /* *************** Variables *************** */
  //
  static const _volumeBtnChannel = MethodChannel("volume_button_channel");
  //
  final quranReadPageScaffoldKey = GlobalKey<ScaffoldState>();
  PageController pageController= PageController(initialPage: 0);
  int currentPage = 0;
  //
  List<Quran> _quran = <Quran>[];
  List<Quran> quranDisplay = <Quran>[];
  //
  bool isLoading = true;
  //
  int page = 293;

  /* *************** Controller life cycle *************** */
  //
  @override
  void onInit() async{
    super.onInit();
    //
   await preparePages();
    //
    _volumeBtnChannel.setMethodCallHandler((call) {
      if (call.method == "volumeBtnPressed") {
        if (call.arguments == "VOLUME_DOWN_UP") {
          pageController.nextPage(
            duration: new Duration(milliseconds: 500),
            curve: Curves.easeIn,
          );
        }
        if (call.arguments == "VOLUME_UP_UP") {
          pageController.previousPage(
            duration: new Duration(milliseconds: 500),
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

  }
  /* *************** Functions *************** */
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
}