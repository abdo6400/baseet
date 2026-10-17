import 'package:dartz/dartz.dart';
import 'package:baseet/core/error/failures.dart';
import 'package:baseet/core/error/repository_call.dart';
import 'package:baseet/features/more_settings/domain/repositories/settings_repository.dart';
import 'package:baseet/features/more_settings/data/datasources/settings_local_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource datasource;
  SettingsRepositoryImpl(this.datasource);
  @override
  Future<Either<Failure, void>> clearData() =>
      repositoryCall(datasource.clearData);
  @override
  Future<Either<Failure, void>> restoreDemoData() =>
      repositoryCall(datasource.restoreDemoData);
}
