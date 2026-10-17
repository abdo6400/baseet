import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/backup_snapshot.dart';
import '../../domain/usecases/transfer_usecases.dart';
import '../../domain/repositories/transfer_repository.dart';

class TransferState {
  final bool busy, restored;
  final String? error, message;
  final TransferSession? session;
  final BackupSnapshot? preview;
  const TransferState(
      {this.busy = false,
      this.restored = false,
      this.error,
      this.message,
      this.session,
      this.preview});
}

class TransferCubit extends Cubit<TransferState> {
  final TransferRepository repository;
  TransferCubit(this.repository) : super(const TransferState());
  Future<void> send() async {
    if (state.busy) return;
    emit(const TransferState(busy: true));
    final result = await StartTransferUseCase(repository)();
    if (!isClosed) {
      result.fold((f) => emit(TransferState(error: f.message)),
          (s) => emit(TransferState(session: s)));
    }
  }

  Future<void> receive(String code) async {
    if (state.busy) return;
    await repository.stop();
    emit(const TransferState(busy: true));
    final result =
        await ReceiveTransferUseCase(repository)(ReceiveParams(code));
    if (!isClosed) {
      result.fold((f) => emit(TransferState(error: f.message)),
          (s) => emit(TransferState(preview: s)));
    }
  }

  Future<void> pick() async {
    if (state.busy) return;
    await repository.stop();
    emit(const TransferState(busy: true));
    final result = await PickBackupUseCase(repository)();
    if (!isClosed) {
      result.fold((f) => emit(TransferState(error: f.message)),
          (s) => emit(TransferState(preview: s)));
    }
  }

  Future<void> save() async {
    if (state.busy) return;
    await repository.stop();
    emit(const TransferState(busy: true));
    final result = await SaveBackupUseCase(repository)();
    if (!isClosed) {
      result.fold(
          (f) => emit(TransferState(error: f.message)),
          (saved) => emit(
              TransferState(message: saved ? 'simple.backup_saved' : null)));
    }
  }

  Future<void> restore() async {
    final preview = state.preview;
    if (state.busy || preview == null) return;
    emit(const TransferState(busy: true));
    final result =
        await RestoreBackupUseCase(repository)(RestoreParams(preview));
    if (!isClosed) {
      result.fold(
          (f) => emit(TransferState(error: f.message)),
          (_) => emit(
              const TransferState(restored: true, message: 'simple.restored')));
    }
  }

  Future<void> stop() async {
    await repository.stop();
    if (!isClosed) emit(const TransferState());
  }

  @override
  Future<void> close() async {
    await repository.stop();
    return super.close();
  }
}
