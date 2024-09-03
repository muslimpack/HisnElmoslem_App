import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hisnelmoslem/src/features/quran/data/models/quran.dart';
import 'package:hisnelmoslem/src/features/quran/data/models/surah_name_enum.dart';

part 'quran_state.dart';

class QuranCubit extends Cubit<QuranState> {
  final _volumeBtnChannel = const MethodChannel("volume_button_channel");
  final PageController pageController = PageController();

  QuranCubit() : super(QuranLoading()) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
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
  }

  FutureOr start(SurahNameEnum surahName) async {
    final quranList = await _fetchQuranJson();
    final requiredSurah = _getQuranRequiredSurah(
      SurahNameEnum.endofAliImran,
      quranList,
    );

    emit(
      QuranLoaded(
        surahName: surahName,
        quranList: quranList,
        requiredSurah: requiredSurah,
      ),
    );
  }

  Quran _getQuranRequiredSurah(
    SurahNameEnum surahName,
    List<Quran> quranList,
  ) {
    switch (surahName) {
      case SurahNameEnum.endofAliImran:
        return quranList[0];
      case SurahNameEnum.alKahf:
        return quranList[1];
      case SurahNameEnum.assajdah:
        return quranList[2];
      case SurahNameEnum.alMulk:
        return quranList[3];
    }
  }

  Future<List<Quran>> _fetchQuranJson() async {
    final String data = await rootBundle.loadString('assets/json/quran.json');

    final quran = <Quran>[];

    final quranJson = json.decode(data);

    if (quranJson is List) {
      for (final item in quranJson) {
        quran.add(Quran.fromJson(item as Map<String, dynamic>));
      }
    }

    return quran;
  }

  @override
  Future<void> close() async {
    pageController.dispose();
    _volumeBtnChannel.setMethodCallHandler(null);

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    return super.close();
  }
}
