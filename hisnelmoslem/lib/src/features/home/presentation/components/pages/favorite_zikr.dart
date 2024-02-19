import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/functions/get_snackbar.dart';
import 'package:hisnelmoslem/src/core/repos/app_data.dart';
import 'package:hisnelmoslem/src/core/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/empty.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/font_settings.dart';
import 'package:hisnelmoslem/src/core/utils/email_manager.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/home/data/repository/azkar_database_helper.dart';
import 'package:hisnelmoslem/src/features/home/presentation/controller/dashboard_controller.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/screens/share_as_image.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/screens/azkar_read_card.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/screens/azkar_read_page.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share/share.dart';

class FavouriteZikr extends StatelessWidget {
  const FavouriteZikr({super.key});

  @override
  Widget build(BuildContext context) {
    //
    return GetBuilder<DashboardController>(
      builder: (controller) {
        return controller.favouriteContent.isEmpty
            ? Empty(
                isImage: false,
                icon: Icons.favorite_outline_rounded,
                title: "nothing found in favorites".tr,
                description:
                    "no zikr has been selected as a favorite Click on the heart icon on any internal zikr"
                        .tr,
              )
            : Scaffold(
                body: Container(
                  margin: const EdgeInsets.only(bottom: 50),
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.favouriteContent.length,
                    itemBuilder: (BuildContext context, int index) {
                      //
                      final DbContent dbContent =
                          controller.favouriteContent[index];
                      //
                      final DbTitle dbTitle = controller.allTitle
                          .where((element) => element.id == dbContent.titleId)
                          .first;
                      //
                      final bool containsAyah = dbContent.content.contains("﴿");
                      return InkWell(
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
                                          ? const Icon(
                                              Icons.favorite,
                                            )
                                          : const Icon(
                                              Icons.favorite_border,
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
                                        icon: const Icon(
                                          Icons.copy,
                                        ),
                                        onPressed: () {
                                          FlutterClipboard.copy(
                                            "${dbContent.content}\n${dbContent.fadl}",
                                          ).then((result) {
                                            getSnackbar(
                                              message: "copied to clipboard".tr,
                                            );
                                          });
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: IconButton(
                                        splashRadius: 20,
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(
                                          Icons.share,
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
                                        icon: const Icon(
                                          Icons.report,
                                          color: Colors.orange,
                                        ),
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
                                const LinearProgressIndicator(
                                  value: 1,
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
                                          height: 2,
                                          fontFamily:
                                              containsAyah ? "Uthmanic2" : null,
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

                                            //fontSize: 20,
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
                                          leading: IconButton(
                                            splashRadius: 20,
                                            onPressed: () async {
                                              await azkarDatabaseHelper
                                                  .getContentsByContentId(
                                                contentId: dbContent.id,
                                              )
                                                  .then((value) {
                                                controller.favouriteContent[
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
                                            style: const TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                          trailing: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Text(
                                              dbContent.count.toString(),
                                              style: const TextStyle(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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
