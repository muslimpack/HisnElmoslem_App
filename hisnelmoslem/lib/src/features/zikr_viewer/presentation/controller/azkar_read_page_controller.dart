// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:hisnelmoslem/src/core/functions/get_snackbar.dart';
// import 'package:hisnelmoslem/src/core/repos/app_data.dart';
// import 'package:hisnelmoslem/src/features/effects_manager/presentation/controller/sounds_manager_controller.dart';
// import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
// import 'package:hisnelmoslem/src/features/home/data/repository/azkar_database_helper.dart';
// import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';

// class AzkarReadPageController extends GetxController {
//   /* *************** Constructor *************** */
//   //
//   final int index;

//   AzkarReadPageController({required this.index});

//   /* *************** Variables *************** */
//   //
//   bool isLoading = true;

//   //
//   //
//   final hReadScaffoldKey = GlobalKey<ScaffoldState>();
//   PageController pageController = PageController();

//   //
//   List<DbContent> zikrContent = <DbContent>[];
//   DbTitle? zikrTitle;

//   //
//   int currentPage = 0;
//   double? totalProgress = 0.0;
//   int zikrCountSum = 0;
//   double? totalProgressForEverySingle = 0.0;

//   //
//   static const _volumeBtnChannel = MethodChannel("volume_button_channel");

//   int? cardNum = 0;

//   DbContent get activeZikr => zikrContent[currentPage];

//   //

//   /* *************** Controller life cycle *************** */
//   //
//   @override
//   Future<void> onInit() async {
//     super.onInit();
//     //
//     if (AppData.instance.enableWakeLock) {
//       WakelockPlus.enable();
//     }

//     ///
//     _volumeBtnChannel.setMethodCallHandler((call) {
//       if (call.method == "volumeBtnPressed") {
//         if (call.arguments == "VOLUME_DOWN_UP" ||
//             call.arguments == "VOLUME_UP_UP") {
//           decreaseCount();
//         }
//         if (call.arguments == "MEDIA_BUTTON_DOWN") {
//           getSnackbar(message: "MEDIA_BUTTON_DOWN");
//         }
//       }

//       return Future.value();
//     });

//     await getReady();
//     getEveryZikrCount();
//     //
//     isLoading = false;
//     //
//     update();
//   }

//   //
//   @override
//   void onClose() {
//     super.onClose();
//     WakelockPlus.disable();
//     pageController.dispose();
//     _volumeBtnChannel.setMethodCallHandler(null);
//   }

//   /* *************** Functions *************** */
//   //

//   Future<void> getReady() async {
//     await azkarDatabaseHelper
//         .getTitleById(id: index)
//         .then((value) => zikrTitle = value);
//     //
//     await azkarDatabaseHelper
//         .getContentsByTitleId(titleId: index)
//         .then((value) => zikrContent = value);

//     isLoading = false;
//     update();
//   }

//   void onPageViewChange(int page) {
//     currentPage = page;
//     update();
//   }

//   void decreaseCount() {
//     int counter = zikrContent[currentPage].count;

//     if (counter > 0) {
//       counter--;

//       zikrContent[currentPage].count = (zikrContent[currentPage].count) - 1;

//       SoundsManagerController().playTallyEffects();
//       if (counter == 0) {
//         SoundsManagerController().playZikrDoneEffects();
//         SoundsManagerController().playTransitionEffects();
//       }
//     }

//     if (counter == 0) {
//       pageController.nextPage(
//         curve: Curves.easeIn,
//         duration: const Duration(milliseconds: 350),
//       );
//     }

//     ///
//     checkProgress();
//     checkProgressForSingle();

//     ///
//     update();
//   }

//   void checkProgress() {
//     int totalNum = 0;
//     int done = 0;
//     totalNum = zikrContent.length;
//     for (var i = 0; i < zikrContent.length; i++) {
//       if (zikrContent[i].count == 0) {
//         done++;
//       }
//     }
//     totalProgress = done / totalNum;
//     if (totalProgress == 1) {
//       ///
//       SoundsManagerController().playAllAzkarFinishedEffects();
//     }
//     update();
//   }

//   void checkProgressForSingle() {
//     int done = 0;
//     for (var i = 0; i < zikrContent.length; i++) {
//       done += zikrContent[i].count;
//     }
//     totalProgressForEverySingle = (zikrCountSum - done) / zikrCountSum;
//     update();
//   }

//   void getEveryZikrCount() {
//     int sum = 0;

//     for (var i = 0; i < zikrContent.length; i++) {
//       sum += zikrContent[i].count;
//     }
//     zikrCountSum = sum;
//     update();
//   }
// }
