import 'package:dartz/dartz.dart';
import '../../../../config/database/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/supplier_entity.dart';
import '../repositories/supplier_repository.dart';

class AddSupplierUseCase extends ParamsUseCase<SupplierEntity, SupplierEntity> {
  final SupplierRepository repository;

  AddSupplierUseCase(this.repository);

  @override
  Future<Either<Failure, SupplierEntity>> call(SupplierEntity params) {
    return repository.addSupplier(params);
  }
}
