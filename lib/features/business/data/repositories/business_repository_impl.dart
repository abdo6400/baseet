import 'package:dartz/dartz.dart';
import 'package:baseet/core/error/failures.dart';
import 'package:baseet/core/error/repository_call.dart';
import 'package:baseet/features/catalog/domain/entities/product_entity.dart';
import '../../domain/entities/business_data.dart';
import '../../domain/repositories/business_repository.dart';
import '../datasources/business_local_datasource.dart';

class BusinessRepositoryImpl implements BusinessRepository {
  final BusinessLocalDataSource source;
  BusinessRepositoryImpl(this.source);
  @override
  Future<Either<Failure, BusinessData>> load() => repositoryCall(source.load);
  @override
  Future<Either<Failure, void>> saveProduct(ProductEntity product) =>
      repositoryCall(() => source.saveProduct(product));
  @override
  Future<Either<Failure, void>> saveStore(String name) =>
      repositoryCall(() => source.saveStore(name));
}
