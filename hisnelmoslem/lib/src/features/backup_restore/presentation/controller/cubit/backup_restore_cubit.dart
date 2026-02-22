import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hisnelmoslem/src/features/backup_restore/data/repository/backup_restore_repo.dart';

part 'backup_restore_state.dart';

class BackupRestoreCubit extends Cubit<BackupRestoreState> {
  final BackupRestoreRepo repo;

  BackupRestoreCubit({required this.repo}) : super(BackupRestoreInitial());

  Future<void> exportData() async {
    emit(BackupRestoreLoading());
    final success = await repo.exportData();
    if (success) {
      emit(const BackupRestoreSuccess(isExport: true));
    } else {
      emit(const BackupRestoreFailure(isExport: true));
    }
  }

  Future<void> importData() async {
    emit(BackupRestoreLoading());
    final success = await repo.importData();
    if (success) {
      emit(const BackupRestoreSuccess(isExport: false));
    } else {
      emit(const BackupRestoreFailure(isExport: false));
    }
  }
}
