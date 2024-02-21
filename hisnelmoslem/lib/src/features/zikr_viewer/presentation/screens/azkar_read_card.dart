import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/extensions/string_extension.dart';
import 'package:hisnelmoslem/src/core/repos/app_data.dart';
import 'package:hisnelmoslem/src/core/shared/dialogs/commentary_dialog.dart';
import 'package:hisnelmoslem/src/core/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/font_settings.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/core/utils/email_manager.dart';
import 'package:hisnelmoslem/src/features/home/presentation/controller/dashboard_controller.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/screens/share_as_image.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/zikr_content_builder.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/controller/azkar_read_card_controller.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share/share.dart';

class AzkarReadCard extends StatelessWidget {
  final int index;

  const AzkarReadCard({super.key, required this.index});

  static DashboardController dashboardController =
      Get.put(DashboardController());

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
                  title: Text(
                    controller.zikrTitle!.name,
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size(100, 5),
                    child: Stack(
                      children: [
                        LinearProgressIndicator(
                          value: controller.totalProgressForEverySingle,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                          backgroundColor: Colors.grey,
                        ),
                        LinearProgressIndicator(
                          value: controller.totalProgress,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context)
                                .primaryColor
                                .withGreen(100)
                                .withAlpha(100),
                          ),
                          backgroundColor: Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                ),
                body: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.zikrContent.length.isNaN
                      ? 0
                      : controller.zikrContent.length,
                  itemBuilder: (context, index) {
                    final dbContent = controller.zikrContent[index];
                    final String text = appData.isDiacriticsEnabled
                        ? dbContent.content
                        : dbContent.content.removeDiacritics;
                    final String source = dbContent.source;
                    final String fadl = dbContent.fadl;
                    final int cardNum = index + 1;
                    int counter = dbContent.count;

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
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: source),
                              );
                              final snackBar = SnackBar(
                                content: Text("copied to clipboard".tr),
                                action: SnackBarAction(
                                  label: "done".tr,
                                  onPressed: () {},
                                ),
                              );
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            },
                          ),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
                                      showCommentaryDialog(
                                        context: Get.context!,
                                        contentId:
                                            controller.zikrContent[index].id,
                                      );
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: IconButton(
                                    splashRadius: 20,
                                    icon: const Icon(MdiIcons.camera),
                                    onPressed: () {
                                      transitionAnimation.circleReval(
                                        context: Get.context!,
                                        goToPage: ShareAsImage(
                                          dbContent:
                                              controller.zikrContent[index],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                if (!controller.zikrContent[index].favourite)
                                  IconButton(
                                    splashRadius: 20,
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.favorite_border,
                                    ),
                                    onPressed: () {
                                      controller.zikrContent[index].favourite =
                                          true;
                                      controller.update();
                                      dashboardController.addContentToFavourite(
                                        controller.zikrContent[index],
                                      );
                                    },
                                  )
                                else
                                  IconButton(
                                    splashRadius: 20,
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.favorite,
                                    ),
                                    onPressed: () {
                                      controller.zikrContent[index].favourite =
                                          false;
                                      controller.update();
                                      dashboardController
                                          .removeContentFromFavourite(
                                        controller.zikrContent[index],
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
                                    onPressed: () async {
                                      await Clipboard.setData(
                                        ClipboardData(text: "$text\n$fadl"),
                                      );
                                      final snackBar = SnackBar(
                                        content: Text("copied to clipboard".tr),
                                        action: SnackBarAction(
                                          label: "done".tr,
                                          onPressed: () {},
                                        ),
                                      );
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
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
                                      Share.share("$text\n$fadl");
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
                                      EmailManager.sendMisspelledInZikrWithText(
                                        subject: controller.zikrTitle!.name,
                                        cardNumber: cardNum.toString(),
                                        text: text,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 20, 10, 5),
                              child: ZikrContentBuilder(
                                dbContent: dbContent,
                                enableDiacritics: appData.isDiacriticsEnabled,
                                fontSize: appData.fontSize * 10,
                              ),
                            ),
                            if (controller.zikrContent[index].fadl == "")
                              const SizedBox()
                            else
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  10,
                                  10,
                                  10,
                                  20,
                                ),
                                child: Text(
                                  controller.zikrContent[index].fadl,
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.rtl,
                                  softWrap: true,
                                  style: TextStyle(
                                    fontSize: appData.fontSize * 10,

                                    //fontSize: 20,
                                  ),
                                ),
                              ),
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                child: Text(
                                  controller.zikrContent[index].count
                                      .toString(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                bottomNavigationBar: BottomAppBar(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(
                        child: FontSettingsToolbox(
                          controllerToUpdate: controller,
                        ),
                      ),
                    ],
                  ),
                ),
              );
      },
    );
  }
}
