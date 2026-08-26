import 'package:dartz/dartz.dart';
import '../../../../config/database/error/failures.dart';
import '../entities/order_entity.dart';
import '../entities/product_entity.dart';

abstract class PosRepository {
  Future<Either<Failure, List<ProductEntity>>> getCatalog({String? categoryId, String? searchQuery});
  Future<Either<Failure, OrderEntity>> checkout(OrderEntity order);
  Future<Either<Failure, double>> getTodaySalesTotal();
}
