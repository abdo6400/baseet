import 'package:dartz/dartz.dart';
import 'package:baseet/features/catalog/data/datasources/catalog_local_datasource.dart';
import 'package:baseet/core/error/failures.dart';
import 'package:baseet/core/error/repository_call.dart';
import 'package:baseet/features/catalog/domain/entities/category_entity.dart';
import 'package:baseet/features/catalog/domain/repositories/catalog_repository.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogLocalDataSource datasource;
  CatalogRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() =>
      repositoryCall(datasource.getCategories);
}
