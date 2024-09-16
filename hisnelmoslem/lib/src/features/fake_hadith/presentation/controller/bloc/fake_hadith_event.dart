// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'fake_hadith_bloc.dart';

sealed class FakeHadithEvent extends Equatable {
  const FakeHadithEvent();

  @override
  List<Object> get props => [];
}

class FakeHadithStartEvent extends FakeHadithEvent {}

class FakeHadithToggleHadithEvent extends FakeHadithEvent {
  final DbFakeHaith fakeHadith;
  final bool isRead;

  const FakeHadithToggleHadithEvent({
    required this.fakeHadith,
    required this.isRead,
  });

  @override
  List<Object> get props => [isRead, fakeHadith];
}

class FakeHadithShareHadithEvent extends FakeHadithEvent {
  final DbFakeHaith fakeHadith;

  const FakeHadithShareHadithEvent({required this.fakeHadith});

  @override
  List<Object> get props => [fakeHadith];
}

class FakeHadithCopyHadithEvent extends FakeHadithEvent {
  final DbFakeHaith fakeHadith;

  const FakeHadithCopyHadithEvent({required this.fakeHadith});

  @override
  List<Object> get props => [fakeHadith];
}

class FakeHadithReportHadithEvent extends FakeHadithEvent {
  final DbFakeHaith fakeHadith;

  const FakeHadithReportHadithEvent({required this.fakeHadith});

  @override
  List<Object> get props => [fakeHadith];
}
