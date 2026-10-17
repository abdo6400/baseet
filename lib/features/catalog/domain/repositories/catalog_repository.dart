import 'package:dartz/dartz.dart';
import 'package:baseet/core/error/failures.dart';
import 'package:baseet/features/catalog/domain/entities/category_entity.dart';

abstract class CatalogRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories();
}
