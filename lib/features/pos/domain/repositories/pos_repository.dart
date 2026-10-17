import 'package:dartz/dartz.dart';
import 'package:baseet/core/error/failures.dart';
import 'package:baseet/features/pos/domain/entities/order_entity.dart';
import 'package:baseet/features/catalog/domain/entities/product_entity.dart';

abstract class PosRepository {
  Future<Either<Failure, List<ProductEntity>>> getCatalog(
      {String? categoryId, String? searchQuery});
  Future<Either<Failure, OrderEntity>> checkout(OrderEntity order);
  Future<Either<Failure, double>> getTodaySalesTotal();
}
