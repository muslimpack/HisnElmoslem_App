part of 'zikr_page_viewer_bloc.dart';

sealed class ZikrPageViewerEvent extends Equatable {
  const ZikrPageViewerEvent();

  @override
  List<Object> get props => [];
}

final class ZikrPageViewerStartEvent extends ZikrPageViewerEvent {
  final int titleIndex;

  const ZikrPageViewerStartEvent({required this.titleIndex});

  @override
  List<Object> get props => [titleIndex];
}

final class ZikrPageViewerDecreaseActiveZikrEvent extends ZikrPageViewerEvent {}

final class ZikrPageViewerResetActiveZikrEvent extends ZikrPageViewerEvent {}

final class ZikrPageViewerCopyActiveZikrEvent extends ZikrPageViewerEvent {}

final class ZikrPageViewerShareActiveZikrEvent extends ZikrPageViewerEvent {}

final class ZikrPageViewerBookmarkActiveZikrEvent extends ZikrPageViewerEvent {}

final class ZikrPageViewerReportActiveZikrEvent extends ZikrPageViewerEvent {}

final class ZikrPageViewerUnbookmarkActiveZikrEvent
    extends ZikrPageViewerEvent {}

class ZikrPageViewerNextTitleEvent extends ZikrPageViewerEvent {}

class ZikrPageViewerPerviousTitleEvent extends ZikrPageViewerEvent {}

class ZikrPageViewerPageChangeEvent extends ZikrPageViewerEvent {
  final int index;

  const ZikrPageViewerPageChangeEvent(this.index);

  @override
  List<Object> get props => [index];
}
