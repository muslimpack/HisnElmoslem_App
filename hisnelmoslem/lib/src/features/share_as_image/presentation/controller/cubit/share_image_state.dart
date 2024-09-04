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
  final String title;
  const ShareImageLoadedState({
    required this.content,
    required this.shareImageSettings,
    required this.showLoadingIndicator,
    required this.title,
  });

  double get dividerSize => 3;
  double get titleFactor => .8;
  double get fadlFactor => .8;
  double get sourceFactor => .7;

  String get getImageTitle {
    if (content.titleId >= 0) {
      if (shareAsImageData.showZikrIndex) {
        return "$title | ذكر رقم ${content.orderId}";
      } else {
        return title;
      }
    } else {
      if (shareAsImageData.showZikrIndex) {
        return "$title | موضوع رقم ${content.orderId}";
      } else {
        return title;
      }
    }
  }

  @override
  List<Object> get props => [
        content,
        shareImageSettings,
        showLoadingIndicator,
        title,
      ];

  ShareImageLoadedState copyWith({
    DbContent? content,
    ShareImageSettings? shareImageSettings,
    bool? showLoadingIndicator,
    String? title,
  }) {
    return ShareImageLoadedState(
      content: content ?? this.content,
      shareImageSettings: shareImageSettings ?? this.shareImageSettings,
      showLoadingIndicator: showLoadingIndicator ?? this.showLoadingIndicator,
      title: title ?? this.title,
    );
  }
}
