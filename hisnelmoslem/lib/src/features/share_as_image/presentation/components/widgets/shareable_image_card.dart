// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_color.dart';
import 'package:hisnelmoslem/src/core/extensions/string_extension.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/models/share_image_settings.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/models/shareable_image_card_settings.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/components/dot_bar.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/components/widgets/share_card_metrics.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/custom_title_source.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_kind.dart';

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
    final kind = zikrTitle.kind;
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

    //TDOD remove after database update
    final displayText = shareImageSettings.removeDiacritics ? mainText.removeDiacritics : mainText;
    final mainStyle = TextStyle(
      fontSize: 150,
      height: 1.45,
      fontFamily: settings.mainFontFamily,
      color: mainColor,
    );
    final titleStyle = TextStyle(
      fontSize: 54,
      height: 1.4,
      fontWeight: FontWeight.bold,
      fontFamily: settings.secondaryFontFamily,
    );

    // A long zikr makes the image taller, up to 2:3; past that its text gets smaller.
    // The whole text is always shown.
    final layout = ShareCardMetrics.layout(
      minHeight: settings.imageSize.height,
      imageWidth: settings.imageSize.width,
      title: zikrTitle.name,
      titleStyle: titleStyle,
      mainText: displayText,
      mainStyle: mainStyle,
      secondaryStyle: secondaryStyle,
      fadl: showFadl ? zikr.fadl : null,
      fadlLabel: kind == ZikrKind.hisn,
      source: showSource ? zikr.source : null,
      count: showCount ? zikr.count : null,
      hasDots: splittedLength > 1,
      hasBadge: kind != ZikrKind.hisn,
    );

    // The picture must not depend on the phone's font scale.
    return MediaQuery.withNoTextScaling(
      child: Container(
        color: background,
        height: layout.height,
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
                            color: accent,
                            fontFamily: settings.secondaryFontFamily,
                          ),
                          const SizedBox(height: 28),
                          Expanded(
                            child: Center(
                              // The size was measured to fit, so nothing is cut or hidden.
                              child: Text(
                                displayText,
                                textAlign: TextAlign.center,
                                style: mainStyle.copyWith(fontSize: layout.mainFontSize),
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
                              showFadlLabel: kind == ZikrKind.hisn,
                              source: showSource ? zikr.source : null,
                              count: showCount ? zikr.count : null,
                            ),
                          ],
                          const SizedBox(height: 24),
                          ShareCardFooter(
                            kind: kind,
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
      ),
    );
  }
}

/// A pill at the bottom left that tells a custom zikr or a fake hadith from a Hisn zikr.
/// A fake hadith is red on purpose, so it can never be mistaken for an authentic one.
class ShareCardKindBadge extends StatelessWidget {
  final ZikrKind kind;
  final Color accent;
  final String fontFamily;

  const ShareCardKindBadge({
    super.key,
    required this.kind,
    required this.accent,
    required this.fontFamily,
  });

  /// Arabic, like the rest of the picture, whatever the app language is.
  static String labelOf(ZikrKind kind) => switch (kind) {
    ZikrKind.hisn => "",
    ZikrKind.custom => "ذكر خاص",
    ZikrKind.fakeHadith => "حديث لا يصح",
  };

  @override
  Widget build(BuildContext context) {
    final isWarning = kind == ZikrKind.fakeHadith;
    final color = isWarning ? Colors.white : accent;
    final icon = isWarning ? Icons.warning_amber_rounded : Icons.edit_note_rounded;

    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: isWarning ? const Color(0xFFC62828) : accent.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(30),
        border: isWarning ? null : Border.all(color: accent, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 8),
          Text(
            labelOf(kind),
            style: TextStyle(
              fontSize: 26,
              height: 1.2,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}

/// The title, with a thin ornament line and diamond underneath.
class ShareCardTitle extends StatelessWidget {
  final String title;
  final Color color;
  final String fontFamily;

  const ShareCardTitle({
    super.key,
    required this.title,
    required this.color,
    required this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AutoSizeText(
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
                    child: Text.rich(
                      TextSpan(
                        children: [
                          if (showFadlLabel) TextSpan(text: "الفضل: ", style: labelStyle),
                          TextSpan(text: fadl),
                        ],
                      ),
                      maxLines: ShareCardMetrics.fadlMaxLines,
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
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: "المصدر: ", style: labelStyle),
                        TextSpan(text: source),
                      ],
                    ),
                    maxLines: ShareCardMetrics.sourceMaxLines,
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

/// App icon and name, with the kind badge at the bottom left for a custom zikr or a fake
/// hadith, and the page dots of a split zikr.
class ShareCardFooter extends StatelessWidget {
  final ZikrKind kind;
  final Color accent;
  final String fontFamily;
  final Widget? dots;

  const ShareCardFooter({
    super.key,
    this.kind = ZikrKind.hisn,
    required this.accent,
    required this.fontFamily,
    this.dots,
  });

  @override
  Widget build(BuildContext context) {
    final brand = Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: TextDirection.rtl,
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
    );

    return Column(
      children: [
        ShareCardRule(color: accent, fadeToEnd: true),
        const SizedBox(height: 18),
        if (kind == ZikrKind.hisn)
          Center(child: brand)
        else
          // The app on the right, the badge on the left, whatever the language.
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: ShareCardKindBadge(kind: kind, accent: accent, fontFamily: fontFamily),
                  ),
                ),
                const Spacer(),
                brand,
              ],
            ),
          ),
        if (dots != null) ...[const SizedBox(height: 10), dots!],
      ],
    );
  }
}
