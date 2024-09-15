part of 'zikr_page_viewer_bloc.dart';

sealed class ZikrPageViewerEvent extends Equatable {
  const ZikrPageViewerEvent();

  @override
  List<Object?> get props => [];
}

final class ZikrPageViewerStartEvent extends ZikrPageViewerEvent {
  final int titleIndex;

  const ZikrPageViewerStartEvent({required this.titleIndex});

  @override
  List<Object> get props => [titleIndex];
}

final class ZikrPageViewerDecreaseActiveZikrEvent extends ZikrPageViewerEvent {
  final DbContent? content;

  const ZikrPageViewerDecreaseActiveZikrEvent({this.content});

  @override
  List<Object?> get props => [content];
}

final class ZikrPageViewerResetActiveZikrEvent extends ZikrPageViewerEvent {
  final DbContent? content;

  const ZikrPageViewerResetActiveZikrEvent({this.content});

  @override
  List<Object?> get props => [content];
}

final class ZikrPageViewerCopyActiveZikrEvent extends ZikrPageViewerEvent {
  final DbContent? content;

  const ZikrPageViewerCopyActiveZikrEvent({this.content});

  @override
  List<Object?> get props => [content];
}

final class ZikrPageViewerShareActiveZikrEvent extends ZikrPageViewerEvent {
  final DbContent? content;

  const ZikrPageViewerShareActiveZikrEvent({this.content});

  @override
  List<Object?> get props => [content];
}

final class ZikrPageViewerToggleActiveZikrBookmarkEvent
    extends ZikrPageViewerEvent {
  final bool bookmark;
  final DbContent? content;

  const ZikrPageViewerToggleActiveZikrBookmarkEvent({
    required this.bookmark,
    this.content,
  });

  @override
  List<Object> get props => [bookmark];
}

final class ZikrPageViewerReportActiveZikrEvent extends ZikrPageViewerEvent {
  final DbContent? content;

  const ZikrPageViewerReportActiveZikrEvent({this.content});

  @override
  List<Object?> get props => [content];
}

class ZikrPageViewerNextTitleEvent extends ZikrPageViewerEvent {}

class ZikrPageViewerPerviousTitleEvent extends ZikrPageViewerEvent {}

class ZikrPageViewerPageChangeEvent extends ZikrPageViewerEvent {
  final int index;

  const ZikrPageViewerPageChangeEvent(this.index);

  @override
  List<Object> get props => [index];
}
