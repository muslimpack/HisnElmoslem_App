// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'share_image_cubit.dart';

sealed class ShareImageState extends Equatable {
  const ShareImageState();

  @override
  List<Object> get props => [];
}

final class ShareImageLoadingState extends ShareImageState {}

class ShareImageLoadedState extends ShareImageState {
  final DbContent content;
  final ShareImageSettings shareImageSettings;
  final bool showLoadingIndicator;
  final DbTitle title;
  final List<TextRange> splittedMatn;

  final ShareableImageCardSettings settings;

  final int activeIndex;

  const ShareImageLoadedState({
    required this.content,
    required this.shareImageSettings,
    required this.showLoadingIndicator,
    required this.title,
    required this.splittedMatn,
    required this.settings,
    required this.activeIndex,
  });

  double get dividerSize => 3;
  double get titleFactor => .8;
  double get fadlFactor => .8;
  double get sourceFactor => .7;

  String get getImageTitle {
    if (content.titleId >= 0) {
      if (shareImageSettings.showZikrIndex) {
        return "$title - ذكر رقم ${content.order}";
      } else {
        return title.name;
      }
    } else {
      if (shareImageSettings.showZikrIndex) {
        return "$title - موضوع رقم ${content.order}";
      } else {
        return title.name;
      }
    }
  }

  @override
  List<Object> get props => [
    content,
    shareImageSettings,
    showLoadingIndicator,
    title,
    splittedMatn,
    settings,
    activeIndex,
  ];

  ShareImageLoadedState copyWith({
    DbContent? content,
    ShareImageSettings? shareImageSettings,
    bool? showLoadingIndicator,
    DbTitle? title,
    List<TextRange>? splittedMatn,
    ShareableImageCardSettings? settings,
    int? activeIndex,
  }) {
    return ShareImageLoadedState(
      content: content ?? this.content,
      shareImageSettings: shareImageSettings ?? this.shareImageSettings,
      showLoadingIndicator: showLoadingIndicator ?? this.showLoadingIndicator,
      title: title ?? this.title,
      splittedMatn: splittedMatn ?? this.splittedMatn,
      settings: settings ?? this.settings,
      activeIndex: activeIndex ?? this.activeIndex,
    );
  }
}
