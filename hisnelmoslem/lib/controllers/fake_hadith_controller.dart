import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/models/fake_haith.dart';
import 'package:hisnelmoslem/temp_utils/fake_hadith_database_helper.dart';

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

  //
  toggleReadState({required DbFakeHaith fakeHaith}) {
    fakeHaith.isRead = !fakeHaith.isRead;
    if (fakeHaith.isRead) {
      fakeHadithDatabaseHelper.markAsRead(dbFakeHaith: fakeHaith);
    } else {
      fakeHadithDatabaseHelper.markAsUnRead(dbFakeHaith: fakeHaith);
    }

    fakeHadithList.sort((a, b) {
      if (b.isRead) {
        return -1;
      }
      return 1;
    });

    update();
  }
}
