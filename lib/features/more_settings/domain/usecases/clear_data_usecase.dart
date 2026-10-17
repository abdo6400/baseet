import 'package:dartz/dartz.dart';
import 'package:baseet/core/error/failures.dart';
import 'package:baseet/core/usecase/usecase.dart';
import 'package:baseet/features/more_settings/domain/repositories/settings_repository.dart';

class ClearDataUseCase extends NoParamsUseCase<void> {
  final SettingsRepository repository;
  ClearDataUseCase(this.repository);
  @override
  Future<Either<Failure, void>> call() => repository.clearData();
}
