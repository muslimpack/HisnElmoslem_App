import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/controllers/tally_controller.dart';
import 'package:hisnelmoslem/shared/widgets/loading.dart';
import 'package:hisnelmoslem/shared/widgets/scroll_glow_custom.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../widgets/cards/tally_card.dart';

class TallyListView extends StatelessWidget {
  const TallyListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TallyController>(builder: (controller) {
      return controller.isLoading
          ? const Loading()
          : Scaffold(
              body: ScrollGlowCustom(
                child: ListView.separated(
                  itemCount: controller.allTally.length,
                  itemBuilder: (context, index) {
                    return TallyCard(dbTally: controller.allTally[index]);
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider();
                  },
                ),
              ),
              floatingActionButton: Align(
                alignment: Alignment.bottomCenter,
                child: FloatingActionButton(
                  child: const Icon(
                    MdiIcons.plus,
                    size: 40,
                  ),
                  onPressed: () {
                    controller.createNewTally();
                  },
                ),
              ),
            );
    });
  }
}
