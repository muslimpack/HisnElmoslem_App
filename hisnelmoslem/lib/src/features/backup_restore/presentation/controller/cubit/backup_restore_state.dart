part of 'backup_restore_cubit.dart';

abstract class BackupRestoreState extends Equatable {
  const BackupRestoreState();

  @override
  List<Object> get props => [];
}

class BackupRestoreInitial extends BackupRestoreState {}

class BackupRestoreLoading extends BackupRestoreState {}

class BackupRestoreSuccess extends BackupRestoreState {
  final bool isExport;

  const BackupRestoreSuccess({required this.isExport});

  @override
  List<Object> get props => [isExport];
}

class BackupRestoreFailure extends BackupRestoreState {
  final bool isExport;

  const BackupRestoreFailure({required this.isExport});

  @override
  List<Object> get props => [isExport];
}
