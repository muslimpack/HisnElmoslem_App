import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

/// The viewer shows user-created titles with a title id of `-(customTitleId + 1)`
/// (always <= -2) and negative content ids (`-itemId`). That keeps them from ever
/// colliding with Hisn al-Muslim ids (sessions, bookmarks, lookups by id) or with
/// the `-1` title id used by the fake hadith screen.
int customViewerTitleId(int customTitleId) => -(customTitleId + 1);

int customTitleIdFromViewerTitleId(int viewerTitleId) => -viewerTitleId - 1;

extension ViewerCustomTitle on DbTitle {
  bool get isCustom => id <= -2;

  /// The custom title id; only meaningful when [isCustom].
  int get customTitleId => customTitleIdFromViewerTitleId(id);
}

extension ViewerCustomContent on DbContent {
  bool get isFromCustomTitle => titleId <= -2;

  /// The custom title id; only meaningful when [isFromCustomTitle].
  int get customTitleId => customTitleIdFromViewerTitleId(titleId);
}
