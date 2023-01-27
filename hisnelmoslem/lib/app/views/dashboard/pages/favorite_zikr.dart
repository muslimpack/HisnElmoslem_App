import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/app/data/app_data.dart';
import "package:hisnelmoslem/app/data/models/models.dart";
import 'package:hisnelmoslem/app/modules/azkar_card.dart/azkar_read_card.dart';
import 'package:hisnelmoslem/app/modules/azkar_page/azkar_read_page.dart';
import 'package:hisnelmoslem/app/modules/share_as_image/share_as_image.dart';
import 'package:hisnelmoslem/app/shared/functions/get_snackbar.dart';
import 'package:hisnelmoslem/app/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/app/shared/widgets/empty.dart';
import 'package:hisnelmoslem/app/shared/widgets/font_settings.dart';
import 'package:hisnelmoslem/app/shared/widgets/scroll_glow_custom.dart';
import 'package:hisnelmoslem/app/views/dashboard/dashboard_controller.dart';
import 'package:hisnelmoslem/core/utils/azkar_database_helper.dart';
import 'package:hisnelmoslem/core/utils/email_manager.dart';
import 'package:hisnelmoslem/core/values/constant.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share/share.dart';

class FavouriteZikr extends StatelessWidget {
  const FavouriteZikr({super.key});

  @override
  Widget build(BuildContext context) {
    //
    return GetBuilder<DashboardController>(
      builder: (controller) {
        return controller.favouriteConent.isEmpty
            ? Empty(
                isImage: false,
                icon: Icons.favorite_outline_rounded,
                title: "nothing found in favourites".tr,
                description:
                    "no zikr has been selected as a favorite Click on the heart icon on any internal zikr"
                        .tr,
              )
            : Scaffold(
                body: Container(
                  margin: const EdgeInsets.only(bottom: 50),
                  child: ScrollGlowCustom(
                    child: ListView.builder(
                      itemCount: controller.favouriteConent.length,
                      itemBuilder: (BuildContext context, int index) {
                        //
                        final DbContent dbContent =
                            controller.favouriteConent[index];
                        //
                        final DbTitle dbTitle = controller.allTitle
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
                                                dbContent: dbContent,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      IconButton(
                                        splashRadius: 20,
                                        padding: EdgeInsets.zero,
                                        icon: dbContent.favourite
                                            ? Icon(
                                                Icons.favorite,
                                                color: mainColor,
                                              )
                                            : Icon(
                                                Icons.favorite_border,
                                                color: mainColor,
                                              ),
                                        onPressed: () {
                                          controller.removeContentFromFavourite(
                                            dbContent,
                                          );
                                        },
                                      ),
                                      Expanded(
                                        child: IconButton(
                                          splashRadius: 20,
                                          padding: EdgeInsets.zero,
                                          icon: Icon(
                                            Icons.copy,
                                            color: mainColor,
                                          ),
                                          onPressed: () {
                                            FlutterClipboard.copy(
                                              "${dbContent.content}\n${dbContent.fadl}",
                                            ).then((result) {
                                              getSnackbar(
                                                message:
                                                    "copied to clipboard".tr,
                                              );
                                            });
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: IconButton(
                                          splashRadius: 20,
                                          padding: EdgeInsets.zero,
                                          icon: Icon(
                                            Icons.share,
                                            color: mainColor,
                                          ),
                                          onPressed: () {
                                            Share.share(
                                              "${dbContent.content}\n${dbContent.fadl}",
                                            );
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: IconButton(
                                          splashRadius: 20,
                                          padding: EdgeInsets.zero,
                                          icon:
                                              Icon(Icons.report, color: orange),
                                          onPressed: () {
                                            EmailManager
                                                .sendMisspelledInZikrWithDbModel(
                                              dbTitle: dbTitle,
                                              dbContent: dbContent,
                                            );
                                          },
                                        ),
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
                                                  RegExp(
                                                    String.fromCharCodes(
                                                      arabicTashkelChar,
                                                    ),
                                                  ),
                                                  "",
                                                ),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: appData.fontSize * 10,
                                            color: dbContent.count == 0
                                                ? mainColor
                                                : null,
                                            //fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      if (dbContent.fadl == "")
                                        const SizedBox()
                                      else
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Text(
                                            dbContent.fadl,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: appData.fontSize * 10,
                                              color: mainColor,
                                              //fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const Divider(),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.zero,
                                          child: ListTile(
                                            // tileColor:
                                            //     Theme.of(context).primaryColor,
                                            leading: IconButton(
                                              splashRadius: 20,
                                              onPressed: () async {
                                                await azkarDatabaseHelper
                                                    .getContentsByContentId(
                                                  contentId: dbContent.id,
                                                )
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
                                                    index: dbTitle.id,
                                                  ),
                                                );
                                              } else {
                                                transitionAnimation.circleReval(
                                                  context: Get.context!,
                                                  goToPage: AzkarReadCard(
                                                    index: dbTitle.id,
                                                  ),
                                                );
                                              }
                                            },
                                            title: Text(
                                              "${"Go to".tr} | ${dbTitle.name}",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: mainColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            trailing: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Text(
                                                dbContent.count.toString(),
                                                style: TextStyle(
                                                  color: mainColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
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
      },
    );
  }
}
