import 'package:dartz/dartz.dart';
import '../../../../config/database/error/failures.dart';
import '../entities/order_entity.dart';
import '../entities/product_entity.dart';

abstract class PosRepository {
  Future<Either<Failure, List<ProductEntity>>> getCatalog({String? categoryId, String? searchQuery});
  Future<Either<Failure, OrderEntity>> checkout(OrderEntity order);
  Future<Either<Failure, double>> getTodaySalesTotal();
  Future<Either<Failure, List<OrderEntity>>> getOrders({String? searchQuery, DateTime? startDate, DateTime? endDate});
  Future<Either<Failure, OrderEntity?>> getOrderById(String orderId);
  Future<Either<Failure, void>> deleteOrder(String orderId);
  Future<Either<Failure, void>> updateOrder(OrderEntity order);
}
