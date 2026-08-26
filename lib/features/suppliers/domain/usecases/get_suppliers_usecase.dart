import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../config/database/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/supplier_entity.dart';
import '../repositories/supplier_repository.dart';

class GetSuppliersParams extends Equatable {
  final String? searchQuery;

  const GetSuppliersParams({this.searchQuery});

  @override
  List<Object?> get props => [searchQuery];
}

class GetSuppliersUseCase extends ParamsUseCase<List<SupplierEntity>, GetSuppliersParams> {
  final SupplierRepository repository;

  GetSuppliersUseCase(this.repository);

  @override
  Future<Either<Failure, List<SupplierEntity>>> call(GetSuppliersParams params) {
    return repository.getSuppliers(searchQuery: params.searchQuery);
  }
}
