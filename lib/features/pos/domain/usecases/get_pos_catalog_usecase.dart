import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../config/database/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/pos_repository.dart';

class GetPosCatalogParams extends Equatable {
  final String? categoryId;
  final String? searchQuery;

  const GetPosCatalogParams({this.categoryId, this.searchQuery});

  @override
  List<Object?> get props => [categoryId, searchQuery];
}

class GetPosCatalogUseCase extends ParamsUseCase<List<ProductEntity>, GetPosCatalogParams> {
  final PosRepository repository;

  GetPosCatalogUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(GetPosCatalogParams params) {
    return repository.getCatalog(
      categoryId: params.categoryId,
      searchQuery: params.searchQuery,
    );
  }
}
