import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/app/shared/dialogs/commentary_dialoge.dart';
import 'package:hisnelmoslem/app/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/app/shared/widgets/loading.dart';
import 'package:hisnelmoslem/app/shared/widgets/scroll_glow_custom.dart';
import 'package:hisnelmoslem/app/views/dashboard/dashboard_controller.dart';
import 'package:hisnelmoslem/core/utils/email_manager.dart';
import 'package:hisnelmoslem/core/values/constant.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share/share.dart';

import '../../data/app_data.dart';
import '../../shared/widgets/font_settings.dart';
import '../share_as_image/share_as_image.dart';
import 'azkar_read_card_controller.dart';

class AzkarReadCard extends StatelessWidget {
  final int index;

  static DashboardController dashboardController =
      Get.put(DashboardController());

  const AzkarReadCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AzkarReadCardController>(
        init: AzkarReadCardController(index: index),
        builder: (controller) {
          return controller.isLoading!
              ? const Loading()
              : Scaffold(
                  key: controller.vReadScaffoldKey,
                  appBar: AppBar(
                    centerTitle: true,
                    title: Text(controller.zikrTitle!.name,
                        style: const TextStyle(fontFamily: "Uthmanic")),
                    bottom: PreferredSize(
                      preferredSize: const Size(100, 5),
                      child: Stack(
                        children: [
                          LinearProgressIndicator(
                            value: controller.totalProgressForEverySingle,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              mainColor,
                            ),
                            backgroundColor: grey,
                          ),
                          LinearProgressIndicator(
                            value: controller.totalProgress,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              mainColor.withGreen(100).withAlpha(100),
                            ),
                            backgroundColor: transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                  body: ScrollGlowCustom(
                    child: ListView.builder(
                      itemCount: controller.zikrContent.length.isNaN
                          ? 0
                          : controller.zikrContent.length,
                      itemBuilder: (context, index) {
                        String text = appData.isTashkelEnabled
                            ? controller.zikrContent[index].content
                            : controller.zikrContent[index].content.replaceAll(
                                //* لحذف التشكيل
                                RegExp(String.fromCharCodes(arabicTashkelChar)),
                                "");
                        String source = controller.zikrContent[index].source;
                        String fadl = controller.zikrContent[index].fadl;
                        int cardnum = index + 1;
                        int counter = controller.zikrContent[index].count;
                        return InkWell(
                          onTap: () {
                            counter = controller.decreaseCount(counter, index);
                          },
                          onLongPress: () {
                            final snackBar = SnackBar(
                              content: Text(
                                source,
                                textAlign: TextAlign.center,
                                softWrap: true,
                              ),
                              action: SnackBarAction(
                                  label: "copy".tr,
                                  onPressed: () {
                                    // Some code to undo the change.
                                    FlutterClipboard.copy(source)
                                        .then((result) {
                                      final snackBar = SnackBar(
                                        content: Text("copied to clipboard".tr),
                                        action: SnackBarAction(
                                          label: "done".tr,
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
                          child: Card(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child: IconButton(
                                      splashRadius: 20,
                                      icon: const Icon(MdiIcons.comment),
                                      onPressed: () {
                                        showCommentaryDialoge(
                                            context: Get.context!,
                                            contentId: controller
                                                .zikrContent[index].id);
                                      },
                                    )),
                                    Expanded(
                                        child: IconButton(
                                      splashRadius: 20,
                                      icon: const Icon(MdiIcons.camera),
                                      onPressed: () {
                                        transitionAnimation.circleReval(
                                            context: Get.context!,
                                            goToPage: ShareAsImage(
                                                dbContent: controller
                                                    .zikrContent[index]));
                                      },
                                    )),
                                    !controller.zikrContent[index].favourite
                                        ? IconButton(
                                            splashRadius: 20,
                                            padding: const EdgeInsets.all(0),
                                            icon: Icon(Icons.favorite_border,
                                                color: mainColor),
                                            onPressed: () {
                                              controller.zikrContent[index]
                                                  .favourite = true;
                                              controller.update();
                                              dashboardController
                                                  .addContentToFavourite(
                                                      controller
                                                          .zikrContent[index]);
                                            })
                                        : IconButton(
                                            splashRadius: 20,
                                            padding: const EdgeInsets.all(0),
                                            icon: Icon(
                                              Icons.favorite,
                                              color: mainColor,
                                            ),
                                            onPressed: () {
                                              controller.zikrContent[index]
                                                  .favourite = false;
                                              controller.update();
                                              dashboardController
                                                  .removeContentFromFavourite(
                                                      controller
                                                          .zikrContent[index]);
                                            }),
                                    Expanded(
                                      flex: 1,
                                      child: IconButton(
                                          splashRadius: 20,
                                          padding: const EdgeInsets.all(0),
                                          icon: Icon(Icons.copy,
                                              color: mainColor),
                                          onPressed: () {
                                            FlutterClipboard.copy(
                                                    "$text\n$fadl")
                                                .then((result) {
                                              final snackBar = SnackBar(
                                                content: Text(
                                                    "copied to clipboard".tr),
                                                action: SnackBarAction(
                                                  label: "done".tr,
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
                                          splashRadius: 20,
                                          padding: const EdgeInsets.all(0),
                                          icon: Icon(Icons.share,
                                              color: mainColor),
                                          onPressed: () {
                                            Share.share("$text\n$fadl");
                                          }),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: IconButton(
                                          splashRadius: 20,
                                          padding: const EdgeInsets.all(0),
                                          icon:
                                              Icon(Icons.report, color: orange),
                                          onPressed: () {
                                            EmailManager
                                                .sendMisspelledInZikrWithText(
                                              subject:
                                                  controller.zikrTitle!.name,
                                              cardNumber: cardnum.toString(),
                                              text: text,
                                            );
                                          }),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 20, 10, 5),
                                  child: Text(
                                    text,
                                    textAlign: TextAlign.center,
                                    softWrap: true,
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                        fontSize: appData.fontSize * 10,
                                        color: controller
                                                    .zikrContent[index].count ==
                                                0
                                            ? mainColor
                                            : null,
                                        //fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                controller.zikrContent[index].fadl == ""
                                    ? const SizedBox()
                                    : Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 10, 10, 20),
                                        child: Text(
                                          controller.zikrContent[index].fadl,
                                          textAlign: TextAlign.center,
                                          textDirection: TextDirection.rtl,
                                          softWrap: true,
                                          style: TextStyle(
                                              fontSize: appData.fontSize * 10,
                                              color: mainColor,
                                              //fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                const Divider(),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: CircleAvatar(
                                    backgroundColor: transparent,
                                    child: Text(
                                      controller.zikrContent[index].count
                                          .toString(),
                                      style: TextStyle(color: mainColor),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomNavigationBar: BottomAppBar(
                    //elevation: 20,
                    // color: Theme.of(context).primaryColor,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Expanded(
                            child: FontSettingsToolbox(
                          controllerToUpdate: controller,
                        )),
                      ],
                    ),
                  ),
                );
        });
  }
}
