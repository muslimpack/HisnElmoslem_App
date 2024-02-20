// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:hisnelmoslem/src/core/repos/app_data.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

class ZikrContentBuilder extends StatelessWidget {
  final DbContent dbContent;
  const ZikrContentBuilder({
    super.key,
    required this.dbContent,
  });

  @override
  Widget build(BuildContext context) {
    final containsQuranText = dbContent.content.contains("QuranText");
    return containsQuranText
        ? ZikrContentTextWithQuran(
            dbContent: dbContent,
          )
        : ZikrContentPlainText(
            dbContent: dbContent,
          );
  }
}

class ZikrContentPlainText extends StatelessWidget {
  final DbContent dbContent;
  const ZikrContentPlainText({
    super.key,
    required this.dbContent,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      dbContent.content,
      textAlign: TextAlign.center,
      softWrap: true,
      textDirection: TextDirection.rtl,
      style: TextStyle(
        fontSize: appData.fontSize * 10,
        height: 2,

        // fontSize: 20,
      ),
    );
  }
}

class ZikrContentTextWithQuran extends StatelessWidget {
  final DbContent dbContent;
  const ZikrContentTextWithQuran({
    super.key,
    required this.dbContent,
  });

  Future<String> getQuranText() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getQuranText(),
      builder: (context, snap) {
        if (!snap.hasData) return const LinearProgressIndicator();
        final List<String> textList = dbContent.content.split("\n");
        textList.indexWhere((e) => e.contains("QuranText"));
        return Text(
          dbContent.content,
          textAlign: TextAlign.center,
          softWrap: true,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: appData.fontSize * 10,
            height: 2,

            // fontSize: 20,
          ),
        );
      },
    );
  }
}
