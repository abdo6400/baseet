import 'package:baseet/core/error/repository_call.dart';
import 'package:dartz/dartz.dart';
import 'package:baseet/core/error/failures.dart';
import 'package:baseet/features/pos/data/datasources/pos_local_datasource.dart';
import 'package:baseet/features/pos/data/models/order_model.dart';
import 'package:baseet/features/pos/domain/entities/order_entity.dart';
import 'package:baseet/features/catalog/domain/entities/product_entity.dart';
import 'package:baseet/features/pos/domain/repositories/pos_repository.dart';

class PosRepositoryImpl implements PosRepository {
  final PosLocalDataSource localDataSource;

  PosRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<ProductEntity>>> getCatalog(
      {String? categoryId, String? searchQuery}) {
    return repositoryCall(() => localDataSource.getCatalog(
          categoryId: categoryId,
          searchQuery: searchQuery,
        ));
  }

  @override
  Future<Either<Failure, OrderEntity>> checkout(OrderEntity order) {
    return repositoryCall(
        () => localDataSource.checkout(OrderModel.fromEntity(order)));
  }

  @override
  Future<Either<Failure, double>> getTodaySalesTotal() {
    return repositoryCall(() => localDataSource.getTodaySalesTotal());
  }
}
