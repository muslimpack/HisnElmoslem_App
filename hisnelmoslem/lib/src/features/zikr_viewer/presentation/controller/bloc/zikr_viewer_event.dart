part of 'zikr_viewer_bloc.dart';

sealed class ZikrViewerEvent extends Equatable {
  const ZikrViewerEvent();

  @override
  List<Object?> get props => [];
}

final class ZikrViewerStartEvent extends ZikrViewerEvent {
  final int titleIndex;
  final ZikrViewerMode zikrViewerMode;

  const ZikrViewerStartEvent({
    required this.titleIndex,
    required this.zikrViewerMode,
  });

  @override
  List<Object> get props => [titleIndex, zikrViewerMode];
}

final class ZikrViewerDecreaseZikrEvent extends ZikrViewerEvent {
  final DbContent? content;

  const ZikrViewerDecreaseZikrEvent({this.content});

  @override
  List<Object?> get props => [content];
}

final class ZikrViewerResetZikrEvent extends ZikrViewerEvent {
  final DbContent? content;

  const ZikrViewerResetZikrEvent({this.content});

  @override
  List<Object?> get props => [content];
}

final class ZikrViewerCopyZikrEvent extends ZikrViewerEvent {
  final DbContent? content;

  const ZikrViewerCopyZikrEvent({this.content});

  @override
  List<Object?> get props => [content];
}

final class ZikrViewerShareZikrEvent extends ZikrViewerEvent {
  final DbContent? content;

  const ZikrViewerShareZikrEvent({this.content});

  @override
  List<Object?> get props => [content];
}

final class ZikrViewerToggleZikrBookmarkEvent extends ZikrViewerEvent {
  final bool bookmark;
  final DbContent? content;

  const ZikrViewerToggleZikrBookmarkEvent({
    required this.bookmark,
    this.content,
  });

  @override
  List<Object> get props => [bookmark];
}

final class ZikrViewerReportZikrEvent extends ZikrViewerEvent {
  final DbContent? content;

  const ZikrViewerReportZikrEvent({this.content});

  @override
  List<Object?> get props => [content];
}

class ZikrViewerNextTitleEvent extends ZikrViewerEvent {}

class ZikrViewerPerviousTitleEvent extends ZikrViewerEvent {}

class ZikrViewerPageChangeEvent extends ZikrViewerEvent {
  final int index;

  const ZikrViewerPageChangeEvent(this.index);

  @override
  List<Object> get props => [index];
}
