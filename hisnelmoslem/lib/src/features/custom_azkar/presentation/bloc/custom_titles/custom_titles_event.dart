part of 'custom_titles_bloc.dart';

sealed class CustomTitlesEvent extends Equatable {
  const CustomTitlesEvent();

  @override
  List<Object?> get props => [];
}

final class CustomTitlesStartEvent extends CustomTitlesEvent {
  const CustomTitlesStartEvent();
}

/// Reload after the editor, alarm editor or a restore changed the data.
final class CustomTitlesRefreshEvent extends CustomTitlesEvent {
  const CustomTitlesRefreshEvent();
}

final class CustomTitlesDeleteEvent extends CustomTitlesEvent {
  final int titleId;
  const CustomTitlesDeleteEvent(this.titleId);

  @override
  List<Object?> get props => [titleId];
}

final class CustomTitlesToggleFavouriteEvent extends CustomTitlesEvent {
  final int titleId;
  final bool favourite;
  const CustomTitlesToggleFavouriteEvent({required this.titleId, required this.favourite});

  @override
  List<Object?> get props => [titleId, favourite];
}

final class CustomZikrToggleFavouriteEvent extends CustomTitlesEvent {
  final int zikrId;
  final bool favourite;
  const CustomZikrToggleFavouriteEvent({required this.zikrId, required this.favourite});

  @override
  List<Object?> get props => [zikrId, favourite];
}
