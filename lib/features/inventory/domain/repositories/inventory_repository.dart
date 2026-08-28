import 'package:dartz/dartz.dart';
import 'package:baseet/config/database/error/failures.dart';
import 'package:baseet/features/inventory/domain/entities/category_entity.dart';
import 'package:baseet/features/pos/domain/entities/product_entity.dart';

abstract class InventoryRepository {
  Future<Either<Failure, List<ProductEntity>>> getInventory({String? categoryId, String? searchQuery, bool onlyLowStock = false});
  Future<Either<Failure, List<CategoryEntity>>> getCategories();
  Future<Either<Failure, ProductEntity>> addProduct(ProductEntity product);
  Future<Either<Failure, CategoryEntity>> addCategory(CategoryEntity category);
  Future<Either<Failure, void>> deleteCategory(String id);
  Future<Either<Failure, Map<String, dynamic>>> getInventoryStats();
}
