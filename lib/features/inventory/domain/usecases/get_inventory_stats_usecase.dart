import 'package:baseet/features/inventory/domain/entities/inventory_stats.dart';
import 'package:dartz/dartz.dart';
import 'package:baseet/core/error/failures.dart';
import 'package:baseet/core/usecase/usecase.dart';
import 'package:baseet/features/inventory/domain/repositories/inventory_repository.dart';

class GetInventoryStatsUseCase extends NoParamsUseCase<InventoryStats> {
  final InventoryRepository repository;

  GetInventoryStatsUseCase(this.repository);

  @override
  Future<Either<Failure, InventoryStats>> call() {
    return repository.getInventoryStats();
  }
}
