import 'package:dartz/dartz.dart';
import 'package:baseet/config/database/error/failures.dart';
import 'package:baseet/core/usecase/usecase.dart';
import 'package:baseet/features/inventory/domain/repositories/inventory_repository.dart';

class GetInventoryStatsUseCase extends NoParamsUseCase<Map<String, dynamic>> {
  final InventoryRepository repository;

  GetInventoryStatsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call() {
    return repository.getInventoryStats();
  }
}
