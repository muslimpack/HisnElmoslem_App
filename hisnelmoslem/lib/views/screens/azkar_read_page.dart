import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/shared/Widgets/Loading.dart';
import 'package:hisnelmoslem/shared/constants/constant.dart';
import 'package:hisnelmoslem/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/shared/functions/send_email.dart';
import 'package:hisnelmoslem/shared/widgets/font_settings.dart';
import 'package:hisnelmoslem/shared/widgets/scroll_glow_custom.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share/share.dart';
import '../../controllers/app_data_controllers.dart';
import '../../controllers/azkar_read_page_controller.dart';
import '../../controllers/dashboard_controller.dart';
import 'share_as_image.dart';

class AzkarReadPage extends StatelessWidget {
  final int index;

  const AzkarReadPage({Key? key, required this.index}) : super(key: key);
  static DashboardController dashboardController =
      Get.put(DashboardController());

  static AppDataController appDataController = Get.put(AppDataController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AzkarReadPageController>(
        init: AzkarReadPageController(index: index),
        builder: (controller) {
          String? text = "";
          String? source = "";
          String? fadl = "";
          int? cardnum = 0;
          if (!controller.isLoading) {
            text = appDataController.isTashkelEnabled
                ? controller.zikrContent[controller.currentPage].content
                : controller.zikrContent[controller.currentPage].content
                    .replaceAll(
                        //* لحذف التشكيل
                        RegExp(String.fromCharCodes(arabicTashkelChar)),
                        "");

            source = controller.zikrContent[controller.currentPage].source;
            fadl = controller.zikrContent[controller.currentPage].fadl;
            cardnum = controller.currentPage + 1;
          }

          return controller.isLoading
              ? const Loading()
              : Scaffold(
                  key: controller.hReadScaffoldKey,
                  appBar: AppBar(
                    centerTitle: true,
                    title: Text(controller.zikrTitle!.name,
                        style: const TextStyle(fontFamily: "Uthmanic")),
                    actions: const [],
                    bottom: PreferredSize(
                      preferredSize: const Size(100, 30),
                      child: Expanded(
                        child: Column(
                          children: [
                            Expanded(
                                child: Row(
                              children: [
                                Expanded(
                                    child: IconButton(
                                  splashRadius: 20,
                                  icon: const Icon(MdiIcons.camera),
                                  onPressed: () {
                                    transitionAnimation.circleReval(
                                        context: Get.context!,
                                        goToPage: ShareAsImage(
                                            dbContent: controller.zikrContent[
                                                controller.currentPage]));
                                  },
                                )),
                                !controller.zikrContent[controller.currentPage]
                                        .favourite
                                    ? Expanded(
                                        child: IconButton(
                                            splashRadius: 20,
                                            padding: const EdgeInsets.all(0),
                                            icon: const Icon(
                                                Icons.favorite_border,
                                                color: mainColor),
                                            onPressed: () {
                                              controller
                                                  .zikrContent[
                                                      controller.currentPage]
                                                  .favourite = true;
                                              controller.update();
                                              //
                                              dashboardController
                                                  .addContentToFavourite(
                                                      controller.zikrContent[
                                                          controller
                                                              .currentPage]);
                                              //
                                              // dashboardController.update();
                                            }),
                                      )
                                    : Expanded(
                                        child: IconButton(
                                            splashRadius: 20,
                                            padding: const EdgeInsets.all(0),
                                            icon: const Icon(
                                              Icons.favorite,
                                              color: mainColor,
                                            ),
                                            onPressed: () {
                                              controller
                                                  .zikrContent[
                                                      controller.currentPage]
                                                  .favourite = false;
                                              controller.update();

                                              dashboardController
                                                  .removeContentFromFavourite(
                                                      controller.zikrContent[
                                                          controller
                                                              .currentPage]);
                                            }),
                                      ),
                                Expanded(
                                  child: IconButton(
                                      splashRadius: 20,
                                      padding: const EdgeInsets.all(0),
                                      icon: const Icon(Icons.share,
                                          color: mainColor),
                                      onPressed: () {
                                        Share.share(text! + "\n" + fadl!);
                                      }),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: CircleAvatar(
                                      backgroundColor: transparent,
                                      child: Text(
                                        controller
                                            .zikrContent[controller.currentPage]
                                            .count
                                            .toString(),
                                        style: const TextStyle(
                                          color: mainColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )),
                            LinearProgressIndicator(
                              value: controller.totalProgress,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                mainColor,
                              ),
                              backgroundColor: grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  body: ScrollGlowCustom(
                    child: PageView.builder(
                      onPageChanged: controller.onPageViewChange,
                      controller: controller.pageController,
                      itemCount: controller.zikrContent.length.isNaN
                          ? 0
                          : controller.zikrContent.length,
                      itemBuilder: (context, index) {
                        /* I repeated this code here to prevent text to be look like
                         the text in the next page when we swipe */
                        String text = appDataController.isTashkelEnabled
                            ? controller.zikrContent[index].content
                            : controller.zikrContent[index].content.replaceAll(
                                //* لحذف التشكيل
                                RegExp(String.fromCharCodes(arabicTashkelChar)),
                                "");
                        return InkWell(
                          onTap: () {
                            controller.decreaseCount();
                          },
                          onLongPress: () {
                            final snackBar = SnackBar(
                              content: Text(
                                source!,
                                textAlign: TextAlign.center,
                                softWrap: true,
                              ),
                              action: SnackBarAction(
                                  label: 'نسخ',
                                  onPressed: () {
                                    // Some code to undo the change.
                                    FlutterClipboard.copy(source!)
                                        .then((result) {
                                      final snackBar = SnackBar(
                                        content:
                                            const Text('تم النسخ إلى الحافظة'),
                                        action: SnackBarAction(
                                          label: 'تم',
                                          onPressed: () {},
                                        ),
                                      );

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                    });
                                  }),
                            );

                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          },
                          child: ListView(
                            physics: const ClampingScrollPhysics(),
                            padding: const EdgeInsets.only(top: 10),
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 20, 10, 5),
                                child: Text(
                                  text,
                                  textAlign: TextAlign.center,
                                  softWrap: true,
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                      fontSize: appDataController.fontSize * 10,
                                      color:
                                          controller.zikrContent[index].count ==
                                                  0
                                              ? mainColor
                                              : null,
                                      // fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 20),
                                child: Text(
                                  controller.zikrContent[index].fadl,
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.rtl,
                                  softWrap: true,
                                  style: TextStyle(
                                      fontSize: appDataController.fontSize * 10,
                                      color: mainColor,
                                      //fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  bottomNavigationBar: BottomAppBar(
                    //elevation: 20,
                    // color: Theme.of(context).primaryColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: IconButton(
                              splashRadius: 20,
                              padding: const EdgeInsets.all(0),
                              icon: const Icon(Icons.copy, color: mainColor),
                              onPressed: () {
                                FlutterClipboard.copy(text! + "\n" + fadl!)
                                    .then((result) {
                                  final snackBar = SnackBar(
                                    content: const Text('تم النسخ إلى الحافظة'),
                                    action: SnackBarAction(
                                      label: 'تم',
                                      onPressed: () {},
                                    ),
                                  );

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                });
                              }),
                        ),
                        Expanded(
                            flex: 3,
                            child: FontSettingsToolbox(
                              controllerToUpdate: controller,
                            )),
                        Expanded(
                          flex: 1,
                          child: IconButton(
                              splashRadius: 20,
                              padding: const EdgeInsets.all(0),
                              icon: Icon(Icons.report, color: orange),
                              onPressed: () {
                                sendEmail(
                                    toMailId: 'hassaneltantawy@gmail.com',
                                    subject: 'تطبيق حصن المسلم: خطأ إملائي ',
                                    body:
                                        ' السلام عليكم ورحمة الله وبركاته يوجد خطأ إملائي في'
                                                '\n'
                                                'الموضوع: ' +
                                            controller.zikrTitle!.name +
                                            '\n' +
                                            'الذكر رقم: ' +
                                            '$cardnum' +
                                            '\n' +
                                            'النص: ' +
                                            '$text' +
                                            '\n' +
                                            'والصواب:' +
                                            '\n');
                              }),
                        ),
                      ],
                    ),
                  ),
                );
        });
  }
}
