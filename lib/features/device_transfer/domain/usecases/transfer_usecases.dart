import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:baseet/core/error/failures.dart';
import 'package:baseet/core/usecase/usecase.dart';
import '../entities/backup_snapshot.dart';
import '../repositories/transfer_repository.dart';

class StartTransferUseCase extends NoParamsUseCase<TransferSession> {
  final TransferRepository repository;
  StartTransferUseCase(this.repository);
  @override
  Future<Either<Failure, TransferSession>> call() => repository.start();
}

class ReceiveParams extends Equatable {
  final String code;
  const ReceiveParams(this.code);
  @override
  List<Object?> get props => [code];
}

class ReceiveTransferUseCase
    extends ParamsUseCase<BackupSnapshot, ReceiveParams> {
  final TransferRepository repository;
  ReceiveTransferUseCase(this.repository);
  @override
  Future<Either<Failure, BackupSnapshot>> call(ReceiveParams params) =>
      repository.receive(params.code);
}

class RestoreParams extends Equatable {
  final BackupSnapshot snapshot;
  const RestoreParams(this.snapshot);
  @override
  List<Object?> get props => [snapshot];
}

class RestoreBackupUseCase extends ParamsUseCase<void, RestoreParams> {
  final TransferRepository repository;
  RestoreBackupUseCase(this.repository);
  @override
  Future<Either<Failure, void>> call(RestoreParams params) =>
      repository.restore(params.snapshot);
}

class SaveBackupUseCase extends NoParamsUseCase<bool> {
  final TransferRepository repository;
  SaveBackupUseCase(this.repository);
  @override
  Future<Either<Failure, bool>> call() => repository.saveBackup();
}

class PickBackupUseCase extends NoParamsUseCase<BackupSnapshot?> {
  final TransferRepository repository;
  PickBackupUseCase(this.repository);
  @override
  Future<Either<Failure, BackupSnapshot?>> call() => repository.pickBackup();
}
