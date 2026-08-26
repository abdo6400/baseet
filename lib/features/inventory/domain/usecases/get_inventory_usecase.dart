import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:baseet/config/database/error/failures.dart';
import 'package:baseet/core/usecase/usecase.dart';
import 'package:baseet/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:baseet/features/pos/domain/entities/product_entity.dart';

class GetInventoryParams extends Equatable {
  final String? categoryId;
  final String? searchQuery;
  final bool onlyLowStock;

  const GetInventoryParams({
    this.categoryId,
    this.searchQuery,
    this.onlyLowStock = false,
  });

  @override
  List<Object?> get props => [categoryId, searchQuery, onlyLowStock];
}

class GetInventoryUseCase extends ParamsUseCase<List<ProductEntity>, GetInventoryParams> {
  final InventoryRepository repository;

  GetInventoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(GetInventoryParams params) {
    return repository.getInventory(
      categoryId: params.categoryId,
      searchQuery: params.searchQuery,
      onlyLowStock: params.onlyLowStock,
    );
  }
}
