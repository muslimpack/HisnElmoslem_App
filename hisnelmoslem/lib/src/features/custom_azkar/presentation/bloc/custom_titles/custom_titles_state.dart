part of 'custom_titles_bloc.dart';

sealed class CustomTitlesState extends Equatable {
  const CustomTitlesState();

  @override
  List<Object?> get props => [];
}

final class CustomTitlesLoadingState extends CustomTitlesState {
  const CustomTitlesLoadingState();
}

final class CustomTitlesLoadedState extends CustomTitlesState {
  final List<CustomTitle> titles;
  final Map<int, CustomAlarm> alarmsByTitleId;
  final List<CustomZikr> favouriteZikrs;

  const CustomTitlesLoadedState({
    required this.titles,
    required this.alarmsByTitleId,
    required this.favouriteZikrs,
  });

  List<CustomTitle> get favouriteTitles => titles.where((e) => e.isFavourite).toList();

  bool hasActiveAlarm(int titleId) => alarmsByTitleId[titleId]?.isActive ?? false;

  @override
  List<Object?> get props => [titles, alarmsByTitleId, favouriteZikrs];
}
