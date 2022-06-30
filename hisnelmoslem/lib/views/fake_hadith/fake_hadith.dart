import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/controllers/fake_hadith_controller.dart';
import 'package:hisnelmoslem/views/fake_hadith/widgets/hadith_card.dart';
import 'package:hisnelmoslem/shared/widgets/scroll_glow_custom.dart';
import '../../shared/widgets/font_settings.dart';

class FakeHadith extends StatelessWidget {
  const FakeHadith({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GetBuilder<FakeHadithController>(
        init: FakeHadithController(),
        builder: (controller) {
          return Scaffold(
            key: controller.fakeHadithScaffoldKey,
            appBar: AppBar(
              centerTitle: true,
              elevation: 0,
              title: const Text("أحاديث منتشرة لا تصح"),
            ),
            body: ScrollGlowCustom(
              child: ListView.builder(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.only(top: 10),
                itemBuilder: (context, index) {
                  return HadithCard(
                    fakeHaith: controller.fakeHadithList[index],
                    scaffoldKey: controller.fakeHadithScaffoldKey,
                  );
                },
                itemCount: controller.fakeHadithList.length,
              ),
            ),
            bottomNavigationBar: BottomAppBar(
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
          );
        });
  }
}
