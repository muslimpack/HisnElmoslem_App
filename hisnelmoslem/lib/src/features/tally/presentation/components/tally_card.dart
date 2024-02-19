import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/controller/tally_controller.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class TallyCard extends StatelessWidget {
  final DbTally dbTally;

  TallyCard({super.key, required this.dbTally});
  final TallyController tallyController = Get.put(TallyController());

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting("ar");

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              isThreeLine: true,
              tileColor: dbTally.isActivated
                  ? Theme.of(context).colorScheme.primary.withOpacity(.2)
                  : null,
              onTap: () {
                if (dbTally.isActivated) {
                  tallyController.deactivateTally(dbTally: dbTally);
                } else {
                  tallyController.activateTally(dbTally);
                }
              },
              leading: Icon(
                dbTally.isActivated
                    ? Icons.done_all_outlined
                    : Icons.done_outline_rounded,
                size: 40,
              ),
              title: Text(
                dbTally.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: "uthmanic",
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    DateFormat('EEEE - dd-MM-yyyy – kk:mm')
                        .format(dbTally.lastUpdate!),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'edit'.tr,
                        onPressed: () {
                          tallyController.updateTallyById(dbTally);
                        },
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        tooltip: "delete".tr,
                        onPressed: () {
                          tallyController.deleteTallyById(dbTally);
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Text(
                dbTally.count.toString(),
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
