// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'share_image_cubit.dart';

sealed class ShareImageState extends Equatable {
  const ShareImageState();

  @override
  List<Object> get props => [];
}

final class ShareImageLoadingState extends ShareImageState {}

class ShareImageLoadedState extends ShareImageState {
  final ShareImageSettings shareImageSettings;
  final bool showLoadingIndicator;
  const ShareImageLoadedState({
    required this.shareImageSettings,
    required this.showLoadingIndicator,
  });

  @override
  List<Object> get props => [
        shareImageSettings,
        showLoadingIndicator,
      ];

  ShareImageLoadedState copyWith({
    ShareImageSettings? shareImageSettings,
    bool? showLoadingIndicator,
  }) {
    return ShareImageLoadedState(
      shareImageSettings: shareImageSettings ?? this.shareImageSettings,
      showLoadingIndicator: showLoadingIndicator ?? this.showLoadingIndicator,
    );
  }
}
