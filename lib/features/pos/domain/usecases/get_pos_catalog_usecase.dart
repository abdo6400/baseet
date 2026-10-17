import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:baseet/core/error/failures.dart';
import 'package:baseet/core/usecase/usecase.dart';
import 'package:baseet/features/catalog/domain/entities/product_entity.dart';
import 'package:baseet/features/pos/domain/repositories/pos_repository.dart';

class GetPosCatalogParams extends Equatable {
  final String? categoryId;
  final String? searchQuery;

  const GetPosCatalogParams({this.categoryId, this.searchQuery});

  @override
  List<Object?> get props => [categoryId, searchQuery];
}

class GetPosCatalogUseCase
    extends ParamsUseCase<List<ProductEntity>, GetPosCatalogParams> {
  final PosRepository repository;

  GetPosCatalogUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(
      GetPosCatalogParams params) {
    return repository.getCatalog(
      categoryId: params.categoryId,
      searchQuery: params.searchQuery,
    );
  }
}
