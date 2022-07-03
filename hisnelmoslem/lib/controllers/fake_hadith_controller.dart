import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/models/fake_haith.dart';
import 'package:hisnelmoslem/utils/fake_hadith_database_helper.dart';

class FakeHadithController extends GetxController {
  /* *************** Variables *************** */
  //
  final fakeHadithScaffoldKey = GlobalKey<ScaffoldState>();

  //
  List<DbFakeHaith> fakeHadithList = <DbFakeHaith>[];

  List<DbFakeHaith> get fakeHadithReadList {
    List<DbFakeHaith> fake = [];
    for (var i = 0; i < fakeHadithList.length; i++) {
      if (fakeHadithList[i].isRead) {
        fake.add(fakeHadithList[i]);
      }
    }

    return fake;
  }

  List<DbFakeHaith> get fakeHadithUnReadList {
    List<DbFakeHaith> fake = [];
    for (var i = 0; i < fakeHadithList.length; i++) {
      if (!fakeHadithList[i].isRead) {
        fake.add(fakeHadithList[i]);
      }
    }

    return fake;
  }

  //get
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
      fakeHadithDatabaseHelper.markFakeHadithAsRead(dbFakeHaith: fakeHaith);
    } else {
      fakeHadithDatabaseHelper.markFakeHadithAsUnRead(dbFakeHaith: fakeHaith);
    }

    update();
  }
}
