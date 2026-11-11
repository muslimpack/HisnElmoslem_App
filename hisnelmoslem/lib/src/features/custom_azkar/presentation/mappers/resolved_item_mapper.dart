import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_title_item.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/custom_title_source.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

extension ResolvedTitleItemViewerMapper on ResolvedTitleItem {
  /// Converts to the model the zikr viewer works with. Ids are negated (see
  /// `custom_title_source.dart`); every item row gets its own id, so the same
  /// original zikr added twice is counted independently.
  DbContent toViewerContent({
    required int customTitleId,
    required int order,
    String userAudioPath = "",
  }) {
    return DbContent(
      id: -item.id,
      content: content,
      titleId: customViewerTitleId(customTitleId),
      // Shown as the zikr number (share image); original azkar are numbered from 1.
      order: order + 1,
      count: item.count,
      fadl: fadl,
      source: source,
      search: "",
      hokm: hokm,
      audio: audio,
      hasAudio: audio.isNotEmpty,
      customZikrId: item.kind == CustomItemKind.custom ? item.refId : null,
      userAudioPath: userAudioPath,
    );
  }
}
