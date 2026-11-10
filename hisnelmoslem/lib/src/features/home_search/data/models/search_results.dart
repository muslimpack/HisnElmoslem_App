import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_title.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_zikr.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

/// A title search hit: a Hisn al-Muslim title or one of the user's custom titles.
sealed class TitleSearchResult {
  const TitleSearchResult();
}

final class OriginalTitleResult extends TitleSearchResult {
  final DbTitle title;
  const OriginalTitleResult(this.title);
}

final class CustomTitleResult extends TitleSearchResult {
  final CustomTitle title;
  const CustomTitleResult(this.title);
}

/// A zikr search hit: a Hisn al-Muslim zikr or one of the user's custom zikrs.
sealed class ContentSearchResult {
  const ContentSearchResult();
}

final class OriginalContentResult extends ContentSearchResult {
  final DbContent content;
  const OriginalContentResult(this.content);
}

final class CustomZikrResult extends ContentSearchResult {
  final CustomZikr zikr;
  const CustomZikrResult(this.zikr);
}
