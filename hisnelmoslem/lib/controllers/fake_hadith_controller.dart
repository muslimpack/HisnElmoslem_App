import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/models/fakeHaith.dart';
import 'package:hisnelmoslem/utils/fake_hadith_database_helper.dart';

class FakeHadithController extends GetxController {
  /* *************** Variables *************** */
  //
  final fakeHadithScaffoldKey = GlobalKey<ScaffoldState>();
  //
  List<DbFakeHaith> fakeHadithList = <DbFakeHaith>[];
  //
  bool isLoading = false;
  //

  /* *************** Controller life cycle *************** */
  //
  @override
  void onInit() {
    super.onInit();
    //
    isLoading = true;
    //
    update();
    //
    getReady();
    //
    isLoading = false;
    //
    update();
  }

  /* *************** Functions *************** */
  //
  getReady() async {
    await fakeHadithDatabaseHelper
        .getAllFakeHadiths()
        .then((value) => fakeHadithList = value);

    isLoading = false;
    update();
  }
}
