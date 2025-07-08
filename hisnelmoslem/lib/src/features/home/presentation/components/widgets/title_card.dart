// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:hisnelmoslem/src/core/extensions/extension.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_platform.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/presentation/components/title_card_alarm_button.dart';
import 'package:hisnelmoslem/src/features/bookmark/presentation/components/bookmark_title_button.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/screens/zikr_viewer_screen.dart';

class TitleCard extends StatelessWidget {
  final Color? titleColor;
  final DbTitle dbTitle;

  const TitleCard({super.key, required this.dbTitle, this.titleColor});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: titleColor,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 25),
                child: Text(dbTitle.order.toString()),
              ),
            ),
          ),
          BookmarkTitleButton(titleId: dbTitle.id),
        ],
      ),

      ///TODO remove when desktop notification is ready
      trailing: PlatformExtension.isDesktop
          ? null
          : TitleCardAlarmButton(dbTitle: dbTitle),
      title: Text(dbTitle.name),
      onTap: () {
        context.push(ZikrViewerScreen(index: dbTitle.id));
      },
    );
  }
}
