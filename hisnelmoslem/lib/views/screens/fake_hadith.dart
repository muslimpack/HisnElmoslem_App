import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/controllers/fake_hadith_controller.dart';
import 'package:hisnelmoslem/providers/app_settings.dart';
import 'package:hisnelmoslem/shared/cards/hadith_card.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class FakeHadith extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appSettings = Provider.of<AppSettingsNotifier>(context);
    return GetBuilder<FakeHadithController>(
        init: FakeHadithController(),
        builder: (controller) {
          return Scaffold(
            key: controller.fakeHadithScaffoldKey,
            appBar: AppBar(
              elevation: 0,
              title: Text("أحاديث منتشرة لا تصح"),
              //backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            ),
            body: ScrollConfiguration(
              behavior: ScrollBehavior(),
              child: GlowingOverscrollIndicator(
                axisDirection: AxisDirection.down,
                color: Colors.black26,
                child: ListView.builder(
                  physics: ClampingScrollPhysics(),
                  padding: EdgeInsets.only(top: 10),
                  itemBuilder: (context, index) {
                    return HadithCard(
                      fakeHaith: controller.fakeHadithList[index],
                      scaffoldKey: controller.fakeHadithScaffoldKey,
                    );
                  },
                  itemCount: controller.fakeHadithList.length,
                ),
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              //elevation: 20,
              color: Theme.of(context).primaryColor,
              child: Container(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                        flex: 1,
                        child: IconButton(
                            icon: Icon(MdiIcons.formatFontSizeIncrease),
                            onPressed: () {
                              appSettings
                                  .setfontSize(appSettings.getfontSize() + 0.3);
                              controller.update();
                            })),
                    Expanded(
                        flex: 1,
                        child: IconButton(
                            icon: Icon(MdiIcons.formatFontSizeDecrease),
                            onPressed: () {
                              appSettings
                                  .setfontSize(appSettings.getfontSize() - 0.3);
                              controller.update();
                            })),

                    /*   */
                  ],
                ),
              ),
            ),
          );
        });
  }
}
