import 'package:baseet/features/inventory/domain/entities/inventory_stats.dart';
import 'package:dartz/dartz.dart';
import 'package:baseet/core/error/failures.dart';
import 'package:baseet/features/catalog/domain/entities/category_entity.dart';
import 'package:baseet/features/catalog/domain/entities/product_entity.dart';

abstract class InventoryRepository {
  Future<Either<Failure, List<ProductEntity>>> getInventory(
      {String? categoryId, String? searchQuery, bool onlyLowStock = false});
  Future<Either<Failure, ProductEntity>> addProduct(ProductEntity product);
  Future<Either<Failure, CategoryEntity>> addCategory(CategoryEntity category);
  Future<Either<Failure, InventoryStats>> getInventoryStats();
}
