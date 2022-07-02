import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/controllers/app_data_controllers.dart';
import 'package:hisnelmoslem/controllers/dashboard_controller.dart';
import 'package:hisnelmoslem/models/zikr_content.dart';
import 'package:hisnelmoslem/models/zikr_title.dart';
import 'package:hisnelmoslem/shared/constants/constant.dart';
import 'package:hisnelmoslem/shared/functions/get_snackbar.dart';
import 'package:hisnelmoslem/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/shared/widgets/empty.dart';
import 'package:hisnelmoslem/shared/widgets/font_settings.dart';
import 'package:hisnelmoslem/shared/widgets/scroll_glow_custom.dart';
import 'package:hisnelmoslem/utils/azkar_database_helper.dart';
import 'package:hisnelmoslem/utils/email_manager.dart';
import 'package:hisnelmoslem/views/azkar/azkar_read_card.dart';
import 'package:hisnelmoslem/views/azkar/azkar_read_page.dart';
import 'package:hisnelmoslem/views/share_as_image/share_as_image.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share/share.dart';

class FavouriteZikr extends StatelessWidget {
  const FavouriteZikr({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    //
    return GetBuilder<DashboardController>(builder: (controller) {
      return controller.favouriteConent.isEmpty
          ? const Empty(
              isImage: false,
              icon: Icons.favorite_outline_rounded,
              title: "لا يوجد شيء في المفضلة",
              description:
                  "لم يتم تحديد أي ذكر كمفضل \nقم بالضغط على علامة القلب ❤ عند أي ذكر داخلي",
            )
          : Scaffold(
              body: Container(
                margin: const EdgeInsets.only(bottom: 50),
                child: ScrollGlowCustom(
                  child: ListView.builder(
                    itemCount: controller.favouriteConent.length,
                    itemBuilder: (BuildContext context, int index) {
                      //
                      late DbContent dbContent =
                          controller.favouriteConent[index];
                      //
                      DbTitle? dbTitle = controller.allTitle
                          .where((element) => element.id == dbContent.titleId)
                          .first;
                      //
                      return InkWell(
                        splashColor: mainColor,
                        onTap: () {
                          if (dbContent.count > 0) {
                            dbContent.count--;
                            controller.update();
                          }
                        },
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child: IconButton(
                                      splashRadius: 20,
                                      icon: const Icon(MdiIcons.camera),
                                      onPressed: () {
                                        transitionAnimation.circleReval(
                                            context: Get.context!,
                                            goToPage: ShareAsImage(
                                                dbContent: dbContent));
                                      },
                                    )),
                                    IconButton(
                                        splashRadius: 20,
                                        padding: const EdgeInsets.all(0),
                                        icon: dbContent.favourite
                                            ? Icon(Icons.favorite,
                                                color: mainColor)
                                            : Icon(Icons.favorite_border,
                                                color: mainColor),
                                        onPressed: () {
                                          controller.removeContentFromFavourite(
                                              dbContent);
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
                                                    "${dbContent.content}\n${dbContent.fadl}")
                                                .then((result) {
                                              // Get.snackbar("رسالة", 'تم النسخ إلى الحافظة');

                                              getSnackbar(
                                                  message:
                                                      'تم النسخ إلى الحافظة');
                                              // Get..currentState!.showSnackBar(snackBar);
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
                                            Share.share("${dbContent.content}\n${dbContent.fadl}");
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
                                                .sendMisspelledInZikrWithDbModel(
                                              dbTitle: dbTitle,
                                              dbContent: dbContent,
                                            );
                                          }),
                                    ),
                                  ],
                                ),
                                LinearProgressIndicator(
                                  value: 1,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    mainColor,
                                  ),
                                  backgroundColor: grey,
                                ),
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        appData.isTashkelEnabled
                                            ? dbContent.content
                                            : dbContent.content.replaceAll(
                                                //* لحذف التشكيل
                                                RegExp(String.fromCharCodes(
                                                    arabicTashkelChar)),
                                                ""),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: appData.fontSize * 10,
                                            color: dbContent.count == 0
                                                ? mainColor
                                                : null,
                                            //fontSize: 20,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    dbContent.fadl == ""
                                        ? const SizedBox()
                                        : Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Text(
                                              dbContent.fadl.toString(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize:
                                                      appData.fontSize * 10,
                                                  color: mainColor,
                                                  //fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                  ],
                                ),
                                const Divider(),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(0.0),
                                        child: ListTile(
                                          // tileColor:
                                          //     Theme.of(context).primaryColor,
                                          leading: IconButton(
                                            splashRadius: 20,
                                            onPressed: () async {
                                              await azkarDatabaseHelper
                                                  .getContentsByContentId(
                                                      contentId: dbContent.id)
                                                  .then((value) {
                                                controller.favouriteConent[
                                                    index] = value;
                                                controller.update();
                                              });
                                            },
                                            icon: const Icon(Icons.repeat),
                                          ),
                                          onTap: () {
                                            if (!appData.isCardReadMode) {
                                              transitionAnimation.circleReval(
                                                  context: Get.context!,
                                                  goToPage: AzkarReadPage(
                                                      index: dbTitle.id));
                                            } else {
                                              transitionAnimation.circleReval(
                                                  context: Get.context!,
                                                  goToPage: AzkarReadCard(
                                                      index: dbTitle.id));
                                            }
                                          },
                                          title: Text(
                                            "الذهاب إلى ${dbTitle.name}",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: mainColor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          trailing: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Text(
                                              dbContent.count.toString(),
                                              style: TextStyle(
                                                  color: mainColor,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              bottomSheet: BottomAppBar(
                child: FontSettingsToolbox(
                  controllerToUpdate: controller,
                ),
              ),
            );
    });
  }
}
