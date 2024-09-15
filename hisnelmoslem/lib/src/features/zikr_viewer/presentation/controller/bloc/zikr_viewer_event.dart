part of 'zikr_viewer_bloc.dart';

sealed class ZikrViewerEvent extends Equatable {
  const ZikrViewerEvent();

  @override
  List<Object?> get props => [];
}

final class ZikrViewerStartEvent extends ZikrViewerEvent {
  final int titleIndex;

  const ZikrViewerStartEvent({required this.titleIndex});

  @override
  List<Object> get props => [titleIndex];
}

final class ZikrViewerDecreaseActiveZikrEvent extends ZikrViewerEvent {
  final DbContent? content;

  const ZikrViewerDecreaseActiveZikrEvent({this.content});

  @override
  List<Object?> get props => [content];
}

final class ZikrViewerResetActiveZikrEvent extends ZikrViewerEvent {
  final DbContent? content;

  const ZikrViewerResetActiveZikrEvent({this.content});

  @override
  List<Object?> get props => [content];
}

final class ZikrViewerCopyActiveZikrEvent extends ZikrViewerEvent {
  final DbContent? content;

  const ZikrViewerCopyActiveZikrEvent({this.content});

  @override
  List<Object?> get props => [content];
}

final class ZikrViewerShareActiveZikrEvent extends ZikrViewerEvent {
  final DbContent? content;

  const ZikrViewerShareActiveZikrEvent({this.content});

  @override
  List<Object?> get props => [content];
}

final class ZikrViewerToggleActiveZikrBookmarkEvent extends ZikrViewerEvent {
  final bool bookmark;
  final DbContent? content;

  const ZikrViewerToggleActiveZikrBookmarkEvent({
    required this.bookmark,
    this.content,
  });

  @override
  List<Object> get props => [bookmark];
}

final class ZikrViewerReportActiveZikrEvent extends ZikrViewerEvent {
  final DbContent? content;

  const ZikrViewerReportActiveZikrEvent({this.content});

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
