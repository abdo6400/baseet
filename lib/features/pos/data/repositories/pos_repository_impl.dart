import 'package:dartz/dartz.dart';
import 'package:baseet/config/database/error/failures.dart';
import 'package:baseet/features/pos/data/datasources/pos_local_datasource.dart';
import 'package:baseet/features/pos/data/models/order_model.dart';
import 'package:baseet/features/pos/domain/entities/order_entity.dart';
import 'package:baseet/features/pos/domain/entities/product_entity.dart';
import 'package:baseet/features/pos/domain/repositories/pos_repository.dart';

class PosRepositoryImpl implements PosRepository {
  final PosLocalDataSource localDataSource;

  PosRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<ProductEntity>>> getCatalog({String? categoryId, String? searchQuery}) {
    return Failure.handleCall(() => localDataSource.getCatalog(
          categoryId: categoryId,
          searchQuery: searchQuery,
        ));
  }

  @override
  Future<Either<Failure, OrderEntity>> checkout(OrderEntity order) {
    return Failure.handleCall(() => localDataSource.checkout(OrderModel.fromEntity(order)));
  }

  @override
  Future<Either<Failure, double>> getTodaySalesTotal() {
    return Failure.handleCall(() => localDataSource.getTodaySalesTotal());
  }
}
