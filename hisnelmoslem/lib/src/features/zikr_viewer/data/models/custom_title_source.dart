import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

/// The viewer shows user-created titles with a **negative** title id
/// (`-customTitleId`) and negative content ids (`-itemId`). That keeps them from
/// ever colliding with Hisn al-Muslim ids (sessions, bookmarks, lookups by id).
extension ViewerCustomTitle on DbTitle {
  bool get isCustom => id < 0;
}

extension ViewerCustomContent on DbContent {
  bool get isFromCustomTitle => titleId < 0;
}
