import 'package:dartz/dartz.dart';
import 'package:baseet/core/error/failures.dart';
import '../entities/backup_snapshot.dart';

abstract class TransferRepository {
  Future<Either<Failure, BackupSnapshot>> snapshot();
  Future<Either<Failure, BackupSnapshot?>> pickBackup();
  Future<Either<Failure, bool>> saveBackup();
  Future<Either<Failure, void>> restore(BackupSnapshot snapshot);
  Future<Either<Failure, TransferSession>> start();
  Future<Either<Failure, BackupSnapshot>> receive(String code);
  Future<void> stop();
}
