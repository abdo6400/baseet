import 'package:dartz/dartz.dart';
import 'package:baseet/config/database/error/failures.dart';
import 'package:baseet/features/inventory/data/datasources/inventory_local_datasource.dart';
import 'package:baseet/features/inventory/data/models/category_model.dart';
import 'package:baseet/features/inventory/domain/entities/category_entity.dart';
import 'package:baseet/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:baseet/features/pos/data/models/product_model.dart';
import 'package:baseet/features/pos/domain/entities/product_entity.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryLocalDataSource localDataSource;

  InventoryRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<ProductEntity>>> getInventory({
    String? categoryId,
    String? searchQuery,
    bool onlyLowStock = false,
  }) {
    return Failure.handleCall(() => localDataSource.getInventory(
          categoryId: categoryId,
          searchQuery: searchQuery,
          onlyLowStock: onlyLowStock,
        ));
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() {
    return Failure.handleCall(() => localDataSource.getCategories());
  }

  @override
  Future<Either<Failure, ProductEntity>> addProduct(ProductEntity product) {
    return Failure.handleCall(() => localDataSource.addProduct(ProductModel.fromEntity(product)));
  }

  @override
  Future<Either<Failure, ProductEntity>> updateProduct(ProductEntity product) {
    return Failure.handleCall(() => localDataSource.updateProduct(ProductModel.fromEntity(product)));
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) {
    return Failure.handleCall(() => localDataSource.deleteProduct(id));
  }

  @override
  Future<Either<Failure, CategoryEntity>> addCategory(CategoryEntity category) {
    return Failure.handleCall(() => localDataSource.addCategory(CategoryModel.fromEntity(category)));
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) {
    return Failure.handleCall(() => localDataSource.deleteCategory(id));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getInventoryStats() {
    return Failure.handleCall(() => localDataSource.getInventoryStats());
  }
}
