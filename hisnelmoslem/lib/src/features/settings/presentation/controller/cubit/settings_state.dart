// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  final ZikrEffects zikrEffects;
  const SettingsState({
    required this.zikrEffects,
  });

  @override
  List<Object> get props => [zikrEffects];

  SettingsState copyWith({
    ZikrEffects? zikrEffects,
  }) {
    return SettingsState(
      zikrEffects: zikrEffects ?? this.zikrEffects,
    );
  }
}
