import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_alarm.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_title.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_zikr.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/repositories/custom_azkar_repo.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/usecases/custom_azkar_usecases.dart';

part 'custom_titles_event.dart';
part 'custom_titles_state.dart';

/// Holds the list of custom titles (plus favourites and alarms flags).
/// App-wide singleton so the tab, favourites and search stay in sync.
class CustomTitlesBloc extends Bloc<CustomTitlesEvent, CustomTitlesState> {
  final CustomAzkarRepo repo;
  final GetCustomTitles _getTitles;
  final DeleteCustomTitle _deleteTitle;
  final ToggleCustomFavourite _toggleFavourite;

  /// Called after a title is deleted so its scheduled notification can be cancelled.
  Future<void> Function(int titleId)? onTitleDeleted;

  CustomTitlesBloc(this.repo)
    : _getTitles = GetCustomTitles(repo),
      _deleteTitle = DeleteCustomTitle(repo),
      _toggleFavourite = ToggleCustomFavourite(repo),
      super(const CustomTitlesLoadingState()) {
    on<CustomTitlesStartEvent>(_load);
    on<CustomTitlesRefreshEvent>(_load);
    on<CustomTitlesDeleteEvent>(_delete);
    on<CustomTitlesToggleFavouriteEvent>(_toggleTitleFavourite);
    on<CustomZikrToggleFavouriteEvent>(_toggleZikrFavourite);
  }

  Future<void> _load(CustomTitlesEvent event, Emitter<CustomTitlesState> emit) async {
    final titles = await _getTitles();
    final alarms = await repo.getAlarms();
    final favouriteZikrs = await repo.getFavouriteZikrs();
    emit(
      CustomTitlesLoadedState(
        titles: titles,
        alarmsByTitleId: {for (final a in alarms) a.titleId: a},
        favouriteZikrs: favouriteZikrs,
      ),
    );
  }

  Future<void> _delete(
    CustomTitlesDeleteEvent event,
    Emitter<CustomTitlesState> emit,
  ) async {
    await _deleteTitle(event.titleId);
    await onTitleDeleted?.call(event.titleId);
    await _load(event, emit);
  }

  Future<void> _toggleTitleFavourite(
    CustomTitlesToggleFavouriteEvent event,
    Emitter<CustomTitlesState> emit,
  ) async {
    await _toggleFavourite.title(event.titleId, favourite: event.favourite);
    await _load(event, emit);
  }

  Future<void> _toggleZikrFavourite(
    CustomZikrToggleFavouriteEvent event,
    Emitter<CustomTitlesState> emit,
  ) async {
    await _toggleFavourite.zikr(event.zikrId, favourite: event.favourite);
    await _load(event, emit);
  }
}
