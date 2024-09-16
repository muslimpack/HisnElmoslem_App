import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/data/models/fake_haith.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/data/repository/fake_hadith_database_helper.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/screens/share_as_image.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

class FakeHadithController extends GetxController {
  final FakeHadithDBHelper fakeHadithDatabaseHelper = sl();
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
    fakeHaith.copyWith(isRead: !fakeHaith.isRead);
    if (fakeHaith.isRead) {
      fakeHadithDatabaseHelper.markFakeHadithAsRead(dbFakeHaith: fakeHaith);
    } else {
      fakeHadithDatabaseHelper.markFakeHadithAsUnRead(dbFakeHaith: fakeHaith);
    }

    update();
  }

  // share as image
  void shareFakehadithAsImage(DbFakeHaith dbFakeHaith) {
    final DbContent dbContent = DbContent(
      id: -1,
      titleId: -1,
      orderId: dbFakeHaith.id,
      content: dbFakeHaith.text,
      fadl: dbFakeHaith.darga,
      source: dbFakeHaith.source,
      count: 0,
      favourite: false,
    );

    transitionAnimation.circleReval(
      context: Get.context!,
      goToPage: ShareAsImage(dbContent: dbContent),
    );
  }
}
