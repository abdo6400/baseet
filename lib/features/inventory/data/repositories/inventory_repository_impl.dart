import 'package:baseet/features/inventory/domain/entities/inventory_stats.dart';
import 'package:baseet/core/error/repository_call.dart';
import 'package:dartz/dartz.dart';
import 'package:baseet/core/error/failures.dart';
import 'package:baseet/features/inventory/data/datasources/inventory_local_datasource.dart';
import 'package:baseet/features/catalog/data/models/category_model.dart';
import 'package:baseet/features/catalog/domain/entities/category_entity.dart';
import 'package:baseet/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:baseet/features/catalog/data/models/product_model.dart';
import 'package:baseet/features/catalog/domain/entities/product_entity.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryLocalDataSource localDataSource;

  InventoryRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<ProductEntity>>> getInventory({
    String? categoryId,
    String? searchQuery,
    bool onlyLowStock = false,
  }) {
    return repositoryCall(() => localDataSource.getInventory(
          categoryId: categoryId,
          searchQuery: searchQuery,
          onlyLowStock: onlyLowStock,
        ));
  }

  @override
  Future<Either<Failure, ProductEntity>> addProduct(ProductEntity product) {
    return repositoryCall(
        () => localDataSource.addProduct(ProductModel.fromEntity(product)));
  }

  @override
  Future<Either<Failure, CategoryEntity>> addCategory(CategoryEntity category) {
    return repositoryCall(
        () => localDataSource.addCategory(CategoryModel.fromEntity(category)));
  }

  @override
  Future<Either<Failure, InventoryStats>> getInventoryStats() {
    return repositoryCall(() => localDataSource.getInventoryStats());
  }
}
