// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'quran_cubit.dart';

sealed class QuranState extends Equatable {
  const QuranState();

  @override
  List<Object> get props => [];
}

final class QuranLoadingState extends QuranState {}

final class QuranLoadedState extends QuranState {
  final SurahNameEnum surahName;
  final List<QuranSurah> quranList;
  final QuranSurah requiredSurah;
  const QuranLoadedState({
    required this.surahName,
    required this.quranList,
    required this.requiredSurah,
  });

  QuranLoadedState copyWith({
    SurahNameEnum? surahName,
    List<QuranSurah>? quranList,
    QuranSurah? requiredSurah,
  }) {
    return QuranLoadedState(
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
