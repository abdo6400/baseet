import 'package:dartz/dartz.dart';
import 'package:baseet/core/error/failures.dart';

abstract class SettingsRepository {
  Future<Either<Failure, void>> clearData();
  Future<Either<Failure, void>> restoreDemoData();
}
