// ignore_for_file: public_member_api_docs, sort_constructors_first
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
  final DbContent content;

  const ZikrViewerDecreaseZikrEvent({required this.content});

  @override
  List<Object?> get props => [content];
}

final class ZikrViewerResetZikrEvent extends ZikrViewerEvent {
  final DbContent content;

  const ZikrViewerResetZikrEvent({required this.content});

  @override
  List<Object?> get props => [content];
}

final class ZikrViewerCopyZikrEvent extends ZikrViewerEvent {
  final DbContent content;

  const ZikrViewerCopyZikrEvent({required this.content});

  @override
  List<Object?> get props => [content];
}

final class ZikrViewerShareZikrEvent extends ZikrViewerEvent {
  final DbContent content;

  const ZikrViewerShareZikrEvent({required this.content});

  @override
  List<Object?> get props => [content];
}

final class ZikrViewerReportZikrEvent extends ZikrViewerEvent {
  final DbContent content;

  const ZikrViewerReportZikrEvent({required this.content});

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

class ZikrViewerRestoreSessionEvent extends ZikrViewerEvent {
  final bool restore;
  const ZikrViewerRestoreSessionEvent(this.restore);

  @override
  List<Object> get props => [restore];
}

class ZikrViewerSaveSessionEvent extends ZikrViewerEvent {
  const ZikrViewerSaveSessionEvent();

  @override
  List<Object> get props => [];
}

class ZikrViewerResetSessionEvent extends ZikrViewerEvent {
  const ZikrViewerResetSessionEvent();

  @override
  List<Object> get props => [];
}

class ZikrViewerVolumeKeyPressedEvent extends ZikrViewerEvent {
  const ZikrViewerVolumeKeyPressedEvent();

  @override
  List<Object> get props => [];
}
