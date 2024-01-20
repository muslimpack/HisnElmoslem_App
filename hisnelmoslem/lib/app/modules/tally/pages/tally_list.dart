import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/app/modules/tally/tally_controller.dart';
import 'package:hisnelmoslem/app/modules/tally/widgets/cards/tally_card.dart';
import 'package:hisnelmoslem/app/shared/widgets/loading.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class TallyListView extends StatelessWidget {
  const TallyListView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TallyController>(
      builder: (controller) {
        return controller.isLoading
            ? const Loading()
            : Scaffold(
                resizeToAvoidBottomInset: false,
                body: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.allTally.length,
                  itemBuilder: (context, index) {
                    return TallyCard(dbTally: controller.allTally[index]);
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider();
                  },
                ),
                floatingActionButton: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton(
                      child: const Icon(
                        MdiIcons.plus,
                        size: 40,
                      ),
                      onPressed: () {
                        controller.createNewTally();
                      },
                    ),
                    FloatingActionButton(
                      child: const Icon(
                        Icons.restart_alt,
                        size: 40,
                      ),
                      onPressed: () {
                        controller.resetAllTally();
                      },
                    ),
                  ],
                ),
              );
      },
    );
  }
}
