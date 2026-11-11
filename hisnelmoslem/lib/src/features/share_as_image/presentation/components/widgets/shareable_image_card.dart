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

/// The picture that is shared: a framed card with the title, the zikr text, its fadl,
/// source and count, and the app name. Colors come from [ShareImageSettings].
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
    final background = shareImageSettings.backgroundColor;
    final accent = shareImageSettings.titleTextColor;
    final mainColor = shareImageSettings.additionalTextColor;
    final contrast = background.getContrastColor;

    final secondaryStyle = TextStyle(
      fontSize: 34,
      height: 1.5,
      color: contrast.withValues(alpha: .85),
      fontFamily: settings.secondaryFontFamily,
    );

    final showSource = shareImageSettings.showSource && zikr.source.isNotEmpty;
    final showFadl = shareImageSettings.showFadl && zikr.fadl.isNotEmpty;
    final showCount = zikr.count > 1;
    final hasDetails = showSource || showFadl || showCount;

    return Container(
      color: background,
      height: settings.imageSize.height,
      width: settings.imageSize.width,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "assets/images/grid.png",
            fit: BoxFit.cover,
            color: contrast.withValues(alpha: .06),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [accent.withValues(alpha: .10), Colors.transparent],
                radius: .9,
              ),
            ),
          ),

          ///MARK: Double frame
          Padding(
            padding: const EdgeInsets.all(36),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(44),
                border: Border.all(color: accent.withValues(alpha: .55), width: 3),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: contrast.withValues(alpha: .05),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: accent.withValues(alpha: .22), width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(48, 44, 48, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ShareCardTitle(
                          title: zikrTitle.name,
                          number: shareImageSettings.showZikrIndex ? zikr.order : null,
                          color: accent,
                          fontFamily: settings.secondaryFontFamily,
                        ),
                        const SizedBox(height: 28),
                        Expanded(
                          child: Center(
                            child: AutoSizeText(
                              //TDOD remove after database update
                              shareImageSettings.removeDiacritics
                                  ? mainText.removeDiacritics
                                  : mainText,
                              minFontSize: 30,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 150,
                                height: 1.45,
                                fontFamily: settings.mainFontFamily,
                                color: mainColor,
                              ),
                            ),
                          ),
                        ),
                        if (hasDetails) ...[
                          const SizedBox(height: 24),
                          ShareCardDetails(
                            accent: accent,
                            textStyle: secondaryStyle,
                            fadl: showFadl ? zikr.fadl : null,
                            // Fake hadith and custom azkar already carry their own wording.
                            showFadlLabel: zikrTitle.id >= 0,
                            source: showSource ? zikr.source : null,
                            count: showCount ? zikr.count : null,
                          ),
                        ],
                        const SizedBox(height: 24),
                        ShareCardFooter(
                          accent: accent,
                          fontFamily: settings.secondaryFontFamily,
                          dots: splittedLength > 1
                              ? DotBar(
                                  activeIndex: splittedindex,
                                  length: splittedLength,
                                  dotColor: accent,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Title with the zikr number in a badge beside it, and a thin ornament line and
/// diamond underneath.
class ShareCardTitle extends StatelessWidget {
  final String title;

  /// Position of the zikr in its title; no badge when null.
  final int? number;
  final Color color;
  final String fontFamily;

  const ShareCardTitle({
    super.key,
    required this.title,
    this.number,
    required this.color,
    required this.fontFamily,
  });

  static const double _badgeSize = 76;

  @override
  Widget build(BuildContext context) {
    final titleText = AutoSizeText(
      title,
      maxLines: 2,
      minFontSize: 28,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 54,
        height: 1.4,
        fontWeight: FontWeight.bold,
        color: color,
        fontFamily: fontFamily,
      ),
    );

    return Column(
      children: [
        if (number == null)
          titleText
        else
          // The same space is kept on both sides, so the title stays centered.
          Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _badgeSize + 20),
                child: SizedBox(width: double.infinity, child: titleText),
              ),
              PositionedDirectional(
                start: 0,
                child: ShareCardNumberBadge(number: number!, color: color, size: _badgeSize),
              ),
            ],
          ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: ShareCardRule(color: color, fadeToEnd: true)),
            const SizedBox(width: 16),
            Transform.rotate(
              angle: 0.785398,
              child: Container(width: 14, height: 14, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(child: ShareCardRule(color: color, fadeToEnd: false)),
          ],
        ),
      ],
    );
  }
}

/// Round badge with the number of the zikr.
class ShareCardNumberBadge extends StatelessWidget {
  final int number;
  final Color color;
  final double size;

  const ShareCardNumberBadge({
    super.key,
    required this.number,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: .14),
        border: Border.all(color: color, width: 3),
      ),
      child: AutoSizeText(
        "$number",
        maxLines: 1,
        minFontSize: 18,
        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

/// A thin line that fades out on one side.
class ShareCardRule extends StatelessWidget {
  final Color color;

  /// Fade towards the right when true, towards the left otherwise.
  final bool fadeToEnd;

  const ShareCardRule({super.key, required this.color, required this.fadeToEnd});

  @override
  Widget build(BuildContext context) {
    final strong = color.withValues(alpha: .8);
    final faded = color.withValues(alpha: 0);

    return Container(
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: fadeToEnd ? [strong, faded] : [faded, strong],
        ),
      ),
    );
  }
}

/// Fadl in a quote block, then the source and the count.
class ShareCardDetails extends StatelessWidget {
  final Color accent;
  final TextStyle textStyle;
  final String? fadl;
  final bool showFadlLabel;
  final String? source;
  final int? count;

  const ShareCardDetails({
    super.key,
    required this.accent,
    required this.textStyle,
    this.fadl,
    this.showFadlLabel = true,
    this.source,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    final smallStyle = textStyle.copyWith(fontSize: (textStyle.fontSize ?? 34) - 4);
    final labelStyle = TextStyle(color: accent, fontWeight: FontWeight.bold);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (fadl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: ColoredBox(
              color: accent.withValues(alpha: .12),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(32, 18, 24, 18),
                    // A long fadl shrinks (then is cut) instead of overflowing the card.
                    child: AutoSizeText.rich(
                      TextSpan(
                        children: [
                          if (showFadlLabel) TextSpan(text: "الفضل: ", style: labelStyle),
                          TextSpan(text: fadl),
                        ],
                      ),
                      maxLines: 5,
                      minFontSize: 22,
                      overflow: TextOverflow.ellipsis,
                      style: textStyle,
                    ),
                  ),
                  // The accent bar, on the reading-start side.
                  PositionedDirectional(
                    start: 0,
                    top: 0,
                    bottom: 0,
                    width: 8,
                    child: ColoredBox(color: accent),
                  ),
                ],
              ),
            ),
          ),
        if (source != null || count != null) ...[
          if (fadl != null) const SizedBox(height: 14),
          Row(
            children: [
              if (source != null)
                Expanded(
                  child: AutoSizeText.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: "المصدر: ", style: labelStyle),
                        TextSpan(text: source),
                      ],
                    ),
                    maxLines: 2,
                    minFontSize: 20,
                    overflow: TextOverflow.ellipsis,
                    style: smallStyle,
                  ),
                )
              else
                const Spacer(),
              if (count != null) ...[
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: accent, width: 2.5),
                  ),
                  child: Text(
                    "عدد المرات: $count",
                    style: smallStyle.copyWith(color: accent, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

/// App icon and name, with the page dots of a split zikr.
class ShareCardFooter extends StatelessWidget {
  final Color accent;
  final String fontFamily;
  final Widget? dots;

  const ShareCardFooter({super.key, required this.accent, required this.fontFamily, this.dots});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShareCardRule(color: accent, fadeToEnd: true),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/app_icon.png", height: 72),
            const SizedBox(width: 18),
            Text(
              "تطبيق حصن المسلم",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: accent,
                fontFamily: fontFamily,
              ),
            ),
          ],
        ),
        if (dots != null) ...[const SizedBox(height: 10), dots!],
      ],
    );
  }
}
