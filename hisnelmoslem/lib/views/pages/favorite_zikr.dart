import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/controllers/dashboard_controller.dart';
import 'package:hisnelmoslem/models/zikr_content.dart';
import 'package:hisnelmoslem/models/zikr_title.dart';
import 'package:hisnelmoslem/shared/constants/constant.dart';
import 'package:hisnelmoslem/shared/functions/send_email.dart';
import 'package:hisnelmoslem/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/shared/widgets/empty.dart';
import 'package:hisnelmoslem/views/screens/azkar_read_card.dart';
import 'package:hisnelmoslem/views/screens/azkar_read_page.dart';
import 'package:hisnelmoslem/views/screens/share_as_image.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share/share.dart';
import '../../controllers/app_data_controllers.dart';
import '../../shared/functions/get_snackbar.dart';
import '../../shared/widgets/font_settings.dart';

class FavouriteZikr extends StatelessWidget {
  final AppDataController appDataController = Get.put(AppDataController());
  @override
  Widget build(BuildContext context) {
    //
    return GetBuilder<DashboardController>(builder: (controller) {
      return controller.favouriteConent.length == 0
          ? Empty(
              isImage: false,
              icon: Icons.favorite_outline_rounded,
              title: "لا يوجد شيء في المفضلة",
              description:
                  "لم يتم تحديد أي ذكر كمفضل \nقم بالضغط على علامة القلب ❤ عند أي ذكر داخلي",
            )
          : Scaffold(
              body: ListView.builder(
                itemCount: controller.favouriteConent.length,
                itemBuilder: (BuildContext context, int index) {
                  //
                  late DbContent dbContent = controller.favouriteConent[index];
                  //
                  DbTitle? dbTitle = controller.allTitle
                      .where((element) => element.id == dbContent.titleId)
                      .first;
                  //
                  return InkWell(
                    splashColor: MAINCOLOR,
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
                                  icon: Icon(MdiIcons.camera),
                                  onPressed: () {
                                    transitionAnimation.circleReval(
                                        context: Get.context!,
                                        goToPage:
                                            ShareAsImage(dbContent: dbContent));
                                  },
                                )),
                                IconButton(
                                    splashRadius: 20,
                                    padding: EdgeInsets.all(0),
                                    icon: dbContent.favourite
                                        ? Icon(Icons.favorite,
                                            color: bleuShade200)
                                        : Icon(Icons.favorite_border,
                                            color: bleuShade200),
                                    onPressed: () {
                                      controller.removeContentFromFavourite(
                                          dbContent);
                                    }),
                                Expanded(
                                  flex: 1,
                                  child: IconButton(
                                      splashRadius: 20,
                                      padding: EdgeInsets.all(0),
                                      icon:
                                          Icon(Icons.copy, color: bleuShade200),
                                      onPressed: () {
                                        FlutterClipboard.copy(
                                                dbContent.content +
                                                    "\n" +
                                                    dbContent.fadl)
                                            .then((result) {
                                          // Get.snackbar("رسالة", 'تم النسخ إلى الحافظة');

                                          getSnackbar(
                                              message: 'تم النسخ إلى الحافظة');
                                          // Get..currentState!.showSnackBar(snackBar);
                                        });
                                      }),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: IconButton(
                                      splashRadius: 20,
                                      padding: EdgeInsets.all(0),
                                      icon: Icon(Icons.share,
                                          color: bleuShade200),
                                      onPressed: () {
                                        Share.share(dbContent.content +
                                            "\n" +
                                            dbContent.fadl);
                                      }),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: IconButton(
                                      splashRadius: 20,
                                      padding: EdgeInsets.all(0),
                                      icon: Icon(Icons.report, color: orange),
                                      onPressed: () {
                                        sendEmail(
                                            toMailId:
                                                'hassaneltantawy@gmail.com',
                                            subject:
                                                'تطبيق حصن المسلم: خطأ إملائي ',
                                            body:
                                                ' السلام عليكم ورحمة الله وبركاته يوجد خطأ إملائي في' +
                                                    '\n' +
                                                    'الموضوع: ' +
                                                    dbTitle.name +
                                                    '\n' +
                                                    'الذكر رقم: ' +
                                                    '${dbContent.orderId}' +
                                                    '\n' +
                                                    'النص: ' +
                                                    '${dbContent.content}' +
                                                    '\n' +
                                                    'والصواب:' +
                                                    '\n');
                                      }),
                                ),
                                // Expanded(
                                //   flex: 1,
                                //   child: IconButton(
                                //     splashRadius: 20,
                                //     onPressed: () {
                                //       //TODO Rest counter
                                //       //  dbContent.count =  ;
                                //       // controller.update();
                                //     },
                                //     icon: Icon(Icons.repeat),
                                //   ),
                                // ),
                              ],
                            ),
                            LinearProgressIndicator(
                              value: 1,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                MAINCOLOR,
                              ),
                              backgroundColor: grey,
                            ),
                            Container(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Text(
                                      appDataController.isTashkelEnabled
                                          ? dbContent.content
                                          : dbContent.content.replaceAll(
                                              //* لحذف التشكيل
                                              new RegExp(String.fromCharCodes(
                                                  arabicTashkelChar)),
                                              ""),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize:
                                              appDataController.fontSize * 10,
                                          color: dbContent.count == 0
                                              ? MAINCOLOR
                                              : white,
                                          //fontSize: 20,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  dbContent.fadl == ""
                                      ? SizedBox()
                                      : Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Text(
                                            dbContent.fadl.toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize:
                                                    appDataController.fontSize *
                                                        10,
                                                color: MAINCOLOR,
                                                //fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: CircleAvatar(
                                      radius: 20,
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      child: Text(
                                        dbContent.count.toString(),
                                        style: TextStyle(color: MAINCOLOR),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: ListTile(
                                tileColor: Theme.of(context).backgroundColor,
                                onTap: () {
                                  if (!appDataController.isCardReadMode) {
                                    transitionAnimation.circleReval(
                                        context: Get.context!,
                                        goToPage:
                                            AzkarReadPage(index: dbTitle.id));
                                  } else {
                                    transitionAnimation.circleReval(
                                        context: Get.context!,
                                        goToPage:
                                            AzkarReadCard(index: dbTitle.id));
                                  }
                                },
                                title: Text(
                                  "الذهاب إلى ${dbTitle.name}",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
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
