// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'fake_hadith_bloc.dart';

sealed class FakeHadithState extends Equatable {
  const FakeHadithState();

  @override
  List<Object> get props => [];
}

final class FakeHadithLoadingState extends FakeHadithState {}

class FakeHadithLoadedState extends FakeHadithState {
  final List<DbFakeHaith> allHadith;

  List<DbFakeHaith> get getReadHadith =>
      allHadith.where((x) => x.isRead).toList();
  List<DbFakeHaith> get getUnreadHadith =>
      allHadith.where((x) => !x.isRead).toList();

  const FakeHadithLoadedState({required this.allHadith});

  @override
  List<Object> get props => [allHadith];

  FakeHadithLoadedState copyWith({
    List<DbFakeHaith>? allHadith,
  }) {
    return FakeHadithLoadedState(
      allHadith: allHadith ?? this.allHadith,
    );
  }
}
