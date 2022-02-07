import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/shared/Widgets/Loading.dart';
import 'package:hisnelmoslem/shared/constants/constant.dart';
import 'package:hisnelmoslem/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/providers/app_settings.dart';
import 'package:hisnelmoslem/shared/functions/send_email.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import '../../controllers/azkar_read_page_controller.dart';
import '../../controllers/dashboard_controller.dart';
import 'share_as_image.dart';

class AzkarReadPage extends StatelessWidget {
  final int index;

  const AzkarReadPage({required this.index});
  static DashboardController dashboardController =
      Get.put(DashboardController());
  @override
  Widget build(BuildContext context) {
    final appSettings = Provider.of<AppSettingsNotifier>(context);
    return GetBuilder<AzkarReadPageController>(
        init: AzkarReadPageController(index: index),
        builder: (controller) {
          String? text = "";
          String? source = "";
          String? fadl = "";
          int? cardnum = 0;
          if (!controller.isLoading) {
            text = appSettings.getTashkelStatus()
                ? controller.zikrContent[controller.currentPage].content
                : controller.zikrContent[controller.currentPage].content
                    .replaceAll(
                        //* لحذف التشكيل
                        new RegExp(String.fromCharCodes([
                          1617,
                          124,
                          1614,
                          124,
                          1611,
                          124,
                          1615,
                          124,
                          1612,
                          124,
                          1616,
                          124,
                          1613,
                          124,
                          1618
                        ])),
                        "");

            source = controller.zikrContent[controller.currentPage].source;
            fadl = controller.zikrContent[controller.currentPage].fadl;
            cardnum = controller.currentPage + 1;
          }

          return controller.isLoading
              ? Loading()
              : Scaffold(
                  key: controller.hReadScaffoldKey,
                  appBar: AppBar(
                    centerTitle: true,
                    title: Text(controller.zikrTitle!.name,
                        style: TextStyle(fontFamily: "Uthmanic")),
                    actions: [],
                    bottom: PreferredSize(
                      preferredSize: Size(100, 30),
                      child: Container(
                        child: Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                  child: Row(
                                children: [
                                  Expanded(
                                      child: IconButton(
                                    splashRadius: 20,
                                    icon: Icon(MdiIcons.camera),
                                    onPressed: () {
                                      transitionAnimation.circleReval(
                                          context: Get.context!,
                                          goToPage: ShareAsImage(
                                              dbContent: controller.zikrContent[
                                                  controller.currentPage]));
                                    },
                                  )),
                                  !controller
                                          .zikrContent[controller.currentPage]
                                          .favourite
                                      ? Expanded(
                                          child: IconButton(
                                              splashRadius: 20,
                                              padding: EdgeInsets.all(0),
                                              icon: Icon(Icons.favorite_border,
                                                  color: bleuShade200),
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
                                              padding: EdgeInsets.all(0),
                                              icon: Icon(
                                                Icons.favorite,
                                                color: bleuShade200,
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
                                        padding: EdgeInsets.all(0),
                                        icon: Icon(Icons.share,
                                            color: bleuShade200),
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
                                              .zikrContent[
                                                  controller.currentPage]
                                              .count
                                              .toString(),
                                          style: TextStyle(
                                            color: blue,
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
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  blue,
                                ),
                                backgroundColor: grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  body: ScrollConfiguration(
                    behavior: ScrollBehavior(),
                    child: GlowingOverscrollIndicator(
                      axisDirection: AxisDirection.left,
                      color: black26,
                      child: PageView.builder(
                        onPageChanged: controller.onPageViewChange,
                        controller: controller.pageController,
                        itemCount: controller.zikrContent.length.isNaN
                            ? 0
                            : controller.zikrContent.length,
                        itemBuilder: (context, index) {
                          /* I repeated this code here to prevent text to be look like
                           the text in the next page when we swipe */
                          String text = appSettings.getTashkelStatus()
                              ? controller.zikrContent[index].content
                              : controller.zikrContent[index].content
                                  .replaceAll(
                                      //* لحذف التشكيل
                                      new RegExp(String.fromCharCodes([
                                        1617,
                                        124,
                                        1614,
                                        124,
                                        1611,
                                        124,
                                        1615,
                                        124,
                                        1612,
                                        124,
                                        1616,
                                        124,
                                        1613,
                                        124,
                                        1618
                                      ])),
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
                                          content: Text('تم النسخ إلى الحافظة'),
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
                              physics: ClampingScrollPhysics(),
                              padding: EdgeInsets.only(top: 10),
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
                                        fontSize:
                                            appSettings.getfontSize() * 10,
                                        color: controller
                                                    .zikrContent[index].count ==
                                                0
                                            ? MAINCOLOR
                                            : white,
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
                                        fontSize:
                                            appSettings.getfontSize() * 10,
                                        color: MAINCOLOR,
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
                              padding: EdgeInsets.all(0),
                              icon: Icon(Icons.copy, color: bleuShade200),
                              onPressed: () {
                                FlutterClipboard.copy(text! + "\n" + fadl!)
                                    .then((result) {
                                  final snackBar = SnackBar(
                                    content: Text('تم النسخ إلى الحافظة'),
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
                            flex: 1,
                            child: IconButton(
                                icon: Icon(MdiIcons.formatFontSizeIncrease),
                                onPressed: () {
                                  appSettings.setfontSize(
                                      appSettings.getfontSize() + 0.3);
                                  controller.update();
                                })),
                        Expanded(
                            flex: 1,
                            child: IconButton(
                                icon: Icon(MdiIcons.formatFontSizeDecrease),
                                onPressed: () {
                                  appSettings.setfontSize(
                                      appSettings.getfontSize() - 0.3);
                                  controller.update();
                                })),
                        Expanded(
                            flex: 1,
                            child: IconButton(
                                icon: Icon(MdiIcons.abjadArabic),
                                onPressed: () {
                                  appSettings.toggleTashkelStatus();
                                  controller.update();
                                })),
                        Expanded(
                          flex: 1,
                          child: IconButton(
                              splashRadius: 20,
                              padding: EdgeInsets.all(0),
                              icon: Icon(Icons.report, color: orange),
                              onPressed: () {
                                sendEmail(
                                    toMailId: 'hassaneltantawy@gmail.com',
                                    subject: 'تطبيق حصن المسلم: خطأ إملائي ',
                                    body:
                                        ' السلام عليكم ورحمة الله وبركاته يوجد خطأ إملائي في' +
                                            '\n' +
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
