import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/app/modules/tally/tally_controller.dart';
import 'package:hisnelmoslem/app/data/models/tally.dart';
import 'package:hisnelmoslem/core/values/constant.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class TallyCard extends StatelessWidget {
  final DbTally dbTally;

  TallyCard({Key? key, required this.dbTally}) : super(key: key);
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
              leading: !dbTally.isActivated
                  ? IconButton(
                      icon: const Icon(Icons.watch_outlined),
                      onPressed: () {
                        tallyController.activateTally(dbTally);
                      },
                      iconSize: 40,
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.watch_outlined,
                        color: mainColor,
                      ),
                      onPressed: () {
                        tallyController.deactivateTally(dbTally: dbTally);
                      },
                      iconSize: 40,
                    ),
              title: Text(
                dbTally.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: "uthmanic",
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(DateFormat('EEEE - dd-MM-yyyy – kk:mm')
                  .format(dbTally.lastUpdate!)),
              trailing: Text(
                dbTally.count.toString(),
                style: TextStyle(
                  color: mainColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
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
            )
          ],
        ),
      ],
    );
  }
}
