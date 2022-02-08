import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/controllers/fake_hadith_controller.dart';
import 'package:hisnelmoslem/shared/cards/hadith_card.dart';
import 'package:hisnelmoslem/shared/constants/constant.dart';

import '../../controllers/app_data_controllers.dart';
import '../../shared/widgets/font_settings.dart';

class FakeHadith extends StatelessWidget {
  FakeHadith({Key? key}) : super(key: key);
  final AppDataController appDataController = Get.put(AppDataController());
  @override
  Widget build(BuildContext context) {
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
                color: black26,
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                        flex: 3,
                        child: FontSettingsToolbox(
                          controllerToUpdate: controller,
                          showTashkelControllers: false,
                        )),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
