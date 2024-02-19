import 'package:flutter/material.dart';
import 'package:get/get.dart';
import "package:hisnelmoslem/app/data/models/models.dart";
import 'package:hisnelmoslem/app/modules/share_as_image/share_as_image.dart';
import 'package:hisnelmoslem/app/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/src/core/utils/fake_hadith_database_helper.dart';

class FakeHadithController extends GetxController {
  /* *************** Variables *************** */
  //
  final fakeHadithScaffoldKey = GlobalKey<ScaffoldState>();

  //
  List<DbFakeHaith> fakeHadithList = <DbFakeHaith>[];

  List<DbFakeHaith> get fakeHadithReadList {
    final List<DbFakeHaith> fake = [];
    for (var i = 0; i < fakeHadithList.length; i++) {
      if (fakeHadithList[i].isRead) {
        fake.add(fakeHadithList[i]);
      }
    }

    return fake;
  }

  List<DbFakeHaith> get fakeHadithUnReadList {
    final List<DbFakeHaith> fake = [];
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
  Future<void> getReady() async {
    await fakeHadithDatabaseHelper
        .getAllFakeHadiths()
        .then((value) => fakeHadithList = value);

    isLoading = false;
    update();
  }

  //
  void toggleReadState({required DbFakeHaith fakeHaith}) {
    fakeHaith.isRead = !fakeHaith.isRead;
    if (fakeHaith.isRead) {
      fakeHadithDatabaseHelper.markFakeHadithAsRead(dbFakeHaith: fakeHaith);
    } else {
      fakeHadithDatabaseHelper.markFakeHadithAsUnRead(dbFakeHaith: fakeHaith);
    }

    update();
  }

  // share as image
  void shareFakehadithAsImage(DbFakeHaith dbFakeHaith) {
    final DbContent dbContent = DbContent();
    dbContent.titleId = -1;
    dbContent.orderId = dbFakeHaith.id;
    //
    dbContent.content = dbFakeHaith.text;
    dbContent.fadl = dbFakeHaith.darga;
    dbContent.source = dbFakeHaith.source;
    //
    transitionAnimation.circleReval(
      context: Get.context!,
      goToPage: ShareAsImage(dbContent: dbContent),
    );
  }
}
