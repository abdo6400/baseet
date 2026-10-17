import 'package:dartz/dartz.dart';
import 'package:baseet/core/error/failures.dart';
import 'package:baseet/features/catalog/domain/entities/product_entity.dart';
import '../entities/business_data.dart';

abstract class BusinessRepository {
  Future<Either<Failure, BusinessData>> load();
  Future<Either<Failure, void>> saveProduct(ProductEntity product);
  Future<Either<Failure, void>> saveStore(String name);
}
