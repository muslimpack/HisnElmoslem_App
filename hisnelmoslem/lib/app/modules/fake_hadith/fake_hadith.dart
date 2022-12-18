import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/app/modules/fake_hadith/fake_hadith_controller.dart';
import 'package:hisnelmoslem/app/modules/fake_hadith/pages/fake_hadith_unread_page.dart';
import 'package:hisnelmoslem/app/shared/widgets/scroll_glow_custom.dart';
import 'package:hisnelmoslem/app/shared/widgets/scroll_glow_remover.dart';

import '../../shared/widgets/font_settings.dart';
import 'pages/fake_hadith_read_page.dart';
import 'widgets/fake_hadith_appbar.dart';

class FakeHadith extends StatelessWidget {
  const FakeHadith({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FakeHadithController>(
        init: FakeHadithController(),
        builder: (controller) {
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              body: ScrollGlowRemover(
                child: NestedScrollView(
                  floatHeaderSlivers: true,
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return [
                      const FakehadithAppBar(),
                    ];
                  },
                  body: ScrollGlowCustom(
                    axisDirection: AxisDirection.right,
                    child: TabBarView(
                      // controller: tabController,
                      children: [
                        FakeHadithUnreadPage(controller: controller),
                        FakeHadithReadPage(controller: controller),
                      ],
                    ),
                  ),
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
            ),
          );
        });
  }
}
