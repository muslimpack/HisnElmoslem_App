// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'quran_cubit.dart';

sealed class QuranState extends Equatable {
  const QuranState();

  @override
  List<Object> get props => [];
}

final class QuranLoading extends QuranState {}

final class QuranLoaded extends QuranState {
  final SurahNameEnum surahName;
  final List<Quran> quranList;
  final Quran requiredSurah;
  const QuranLoaded({
    required this.surahName,
    required this.quranList,
    required this.requiredSurah,
  });

  QuranLoaded copyWith({
    SurahNameEnum? surahName,
    List<Quran>? quranList,
    Quran? requiredSurah,
  }) {
    return QuranLoaded(
      surahName: surahName ?? this.surahName,
      quranList: quranList ?? this.quranList,
      requiredSurah: requiredSurah ?? this.requiredSurah,
    );
  }

  @override
  List<Object> get props => [
        surahName,
        quranList,
        requiredSurah,
      ];
}
