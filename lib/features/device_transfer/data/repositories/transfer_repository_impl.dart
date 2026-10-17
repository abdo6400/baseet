import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:dartz/dartz.dart';
import 'package:file_selector/file_selector.dart';
import 'package:baseet/core/error/failures.dart';
import 'package:baseet/core/error/repository_call.dart';
import '../../domain/entities/backup_snapshot.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../datasources/backup_datasource.dart';
import '../datasources/local_transfer.dart';

class TransferRepositoryImpl implements TransferRepository {
  final BackupDataSource backup;
  final LocalTransfer transfer;
  TransferRepositoryImpl(this.backup, this.transfer);
  @override
  Future<Either<Failure, BackupSnapshot>> snapshot() =>
      repositoryCall(backup.export);
  @override
  Future<Either<Failure, BackupSnapshot?>> pickBackup() =>
      repositoryCall(() async {
        final file = await openFile(acceptedTypeGroups: [
          const XTypeGroup(
              label: 'Baseet backup',
              extensions: ['baseet'],
              uniformTypeIdentifiers: ['public.data'])
        ]);
        if (file == null) return null;
        if (await file.length() > BackupDataSource.maxBytes) backup.invalid();
        return backup.inspect(await file.readAsString());
      });
  @override
  Future<Either<Failure, bool>> saveBackup() => repositoryCall(() async {
        final data = await backup.export();
        final result = await FilePicker.saveFile(
            fileName:
                'baseet-${DateTime.now().toIso8601String().substring(0, 10)}.baseet',
            type: FileType.custom,
            allowedExtensions: ['baseet'],
            bytes: Uint8List.fromList(utf8.encode(data.contents)));
        return result != null;
      });
  @override
  Future<Either<Failure, void>> restore(BackupSnapshot snapshot) =>
      repositoryCall(() => backup.restore(snapshot));
  @override
  Future<Either<Failure, TransferSession>> start() => repositoryCall(
      () async => transfer.start((await backup.export()).contents));
  @override
  Future<Either<Failure, BackupSnapshot>> receive(String code) =>
      repositoryCall(() async => backup.inspect(await transfer.receive(code)));
  @override
  Future<void> stop() => transfer.stop();
}
