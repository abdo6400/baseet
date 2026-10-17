import 'package:dartz/dartz.dart';
import 'package:baseet/core/error/failures.dart';
import 'package:baseet/core/usecase/usecase.dart';
import 'package:baseet/features/catalog/domain/entities/category_entity.dart';
import 'package:baseet/features/catalog/domain/repositories/catalog_repository.dart';

class GetCategoriesUseCase extends NoParamsUseCase<List<CategoryEntity>> {
  final CatalogRepository repository;

  GetCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<CategoryEntity>>> call() {
    return repository.getCategories();
  }
}
