import 'package:flutter/material.dart';
import 'package:get/get.dart';
import "package:hisnelmoslem/app/data/models/models.dart";
import 'package:hisnelmoslem/app/modules/tally/tally_controller.dart';
import 'package:hisnelmoslem/core/values/constant.dart';
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
              tileColor: dbTally.isActivated ? mainColor.withOpacity(.2) : null,
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
                  fontWeight: FontWeight.bold,
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
                      Expanded(
                        child: ListTile(
                          leading: const Icon(Icons.edit),
                          title: Text(
                            'edit'.tr,
                            textAlign: TextAlign.center,
                          ),
                          onTap: () {
                            tallyController.updateTallyById(dbTally);
                          },
                        ),
                      ),
                      const VerticalDivider(),
                      Expanded(
                        child: ListTile(
                          leading: const Icon(Icons.delete),
                          title: Text(
                            "delete".tr,
                            textAlign: TextAlign.center,
                          ),
                          onTap: () {
                            tallyController.deleteTallyById(dbTally);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Text(
                dbTally.count.toString(),
                style: TextStyle(
                  color: mainColor,
                  fontWeight: FontWeight.bold,
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
