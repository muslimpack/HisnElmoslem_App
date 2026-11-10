import 'package:flutter/material.dart';
import 'package:hisnelmoslem/src/core/extensions/zikr_extension.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

/// Shows a short plain-text preview of a zikr. Original zikrs may contain Quran
/// range markup, which is resolved to the verse text like the viewer does.
class ZikrPreviewText extends StatelessWidget {
  final String content;
  final int maxLines;

  const ZikrPreviewText({super.key, required this.content, this.maxLines = 3});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.bodyLarge?.copyWith(fontFamily: "Kitab", height: 1.8);

    if (!content.contains("QuranText")) {
      return Text(content, maxLines: maxLines, overflow: TextOverflow.ellipsis, style: style);
    }

    return FutureBuilder<String>(
      future: _previewContent(content).toPlainText(),
      builder: (context, snapshot) {
        return Text(
          snapshot.data ?? "…",
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: style,
        );
      },
    );
  }
}

DbContent _previewContent(String content) {
  return DbContent(
    id: 0,
    content: content,
    titleId: 0,
    order: 0,
    count: 1,
    fadl: "",
    source: "",
    search: "",
    hokm: "",
    audio: "",
    hasAudio: false,
  );
}
