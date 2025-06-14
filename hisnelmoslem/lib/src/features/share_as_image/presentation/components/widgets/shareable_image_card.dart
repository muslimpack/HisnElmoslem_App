// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_color.dart';
import 'package:hisnelmoslem/src/core/extensions/string_extension.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/models/share_image_settings.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/models/shareable_image_card_settings.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/components/dot_bar.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

class ShareableImageCard extends StatelessWidget {
  final DbTitle zikrTitle;
  final DbContent zikr;
  final ShareableImageCardSettings settings;
  final TextRange? matnRange;
  final int splittedLength;
  final int splittedindex;

  final ShareImageSettings shareImageSettings;

  const ShareableImageCard({
    super.key,
    required this.zikrTitle,
    required this.zikr,
    required this.settings,
    this.matnRange,
    this.splittedLength = 0,
    this.splittedindex = 0,
    required this.shareImageSettings,
  });

  String get mainText {
    const String separator = "...";
    String mainText = matnRange != null
        ? zikr.content.substring(matnRange!.start, matnRange!.end)
        : zikr.content;

    if (splittedLength > 1) {
      if (splittedindex == 0) {
        mainText += separator;
      } else if (splittedindex == splittedLength - 1) {
        mainText = "$separator$mainText";
      } else {
        mainText = "$separator$mainText$separator";
      }
    }

    return mainText;
  }

  @override
  Widget build(BuildContext context) {
    final imageBackgroundColor = shareImageSettings.backgroundColor;
    final secondaryColor = shareImageSettings.backgroundColor;
    //todo depened on zikr hokm
    final secondaryElementsColor = Colors.brown.withValues(alpha: .15);

    final mainTextStyle = TextStyle(
      fontSize: 150,
      fontFamily: settings.mainFontFamily,
      color: shareImageSettings.additionalTextColor,
    );

    final secondaryTextStyle = TextStyle(
      fontSize: 35,
      color: shareImageSettings.titleTextColor,
      fontFamily: settings.secondaryFontFamily,
      fontWeight: FontWeight.bold,
    );

    final whetherShowSource =
        shareImageSettings.showSource && zikr.source.isNotEmpty;
    final whetherShowFadl = shareImageSettings.showFadl && zikr.fadl.isNotEmpty;
    final whetherShowCount = zikr.count > 1;

    return Container(
      color: imageBackgroundColor,
      height: settings.imageSize.height,
      width: settings.imageSize.width,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "assets/images/grid.png",
            fit: BoxFit.cover,
            color: imageBackgroundColor.getContrastColor.withValues(alpha: .07),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [imageBackgroundColor, Colors.transparent],
                radius: 1,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(40).copyWith(top: 60, bottom: 60),
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .11),
              border: Border.all(color: secondaryElementsColor, width: 5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
                bottomRight: Radius.circular(50),
                bottomLeft: Radius.circular(255),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  zikrTitle.name +
                      (shareImageSettings.showZikrIndex
                          ? " :: ${zikr.order}"
                          : ""),
                  textAlign: TextAlign.center,
                  style: secondaryTextStyle.copyWith(fontSize: 45),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: Center(
                    child: AutoSizeText(
                      //TDOD remove after database update
                      shareImageSettings.removeDiacritics
                          ? (mainText.removeDiacritics)
                          : mainText,
                      minFontSize: 30,
                      textAlign: TextAlign.center,
                      style: mainTextStyle,
                    ),
                  ),
                ),

                ///MARK: fadl and count
                if (whetherShowFadl ||
                    whetherShowSource ||
                    whetherShowCount) ...[
                  const SizedBox(height: 30),
                ],

                if (whetherShowFadl) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 65),
                    child: Text(
                      zikrTitle.id < 0 ? zikr.fadl : "🏆 الفضل: ${zikr.fadl}",
                      style: secondaryTextStyle,
                    ),
                  ),
                ],

                if (whetherShowSource) ...[
                  Text("📚 المصدر: ${zikr.source}", style: secondaryTextStyle),
                ],
                if (whetherShowCount) ...[
                  Text(
                    "🔢 عدد مرات الذكر: ${zikr.count}",
                    style: secondaryTextStyle,
                  ),
                ],
                if (!whetherShowCount &&
                    !whetherShowFadl &&
                    !whetherShowSource) ...[
                  const SizedBox(height: 50),
                ],
              ],
            ),
          ),
          if (splittedLength > 1)
            Padding(
              padding: const EdgeInsets.all(15).copyWith(left: 200, right: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DotBar(
                    activeIndex: splittedindex,
                    length: splittedLength,
                    dotColor: secondaryColor,
                  ),
                ],
              ),
            ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Image.asset("assets/images/app_icon.png", height: 100),
            ),
          ),
        ],
      ),
    );
  }
}
