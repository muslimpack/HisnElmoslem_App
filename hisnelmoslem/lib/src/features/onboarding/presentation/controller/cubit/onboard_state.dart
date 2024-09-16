// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'onboard_cubit.dart';

sealed class OnboardState extends Equatable {
  const OnboardState();

  @override
  List<Object> get props => [];
}

final class OnboardLoadingState extends OnboardState {}

class OnboardLoadedState extends OnboardState {
  final int currentPageIndex;
  final bool showSkipBtn;
  final List<Empty> pages;

  const OnboardLoadedState({
    required this.currentPageIndex,
    required this.showSkipBtn,
    required this.pages,
  });

  bool get isFinalPage => currentPageIndex + 1 == pages.length;

  OnboardLoadedState copyWith({
    int? currentPageIndex,
    bool? showSkipBtn,
    List<Empty>? pages,
  }) {
    return OnboardLoadedState(
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      showSkipBtn: showSkipBtn ?? this.showSkipBtn,
      pages: pages ?? this.pages,
    );
  }

  @override
  List<Object> get props => [
        currentPageIndex,
        showSkipBtn,
        pages,
      ];
}

class OnboardDoneState extends OnboardState {}
