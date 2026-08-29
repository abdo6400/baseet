import 'package:dartz/dartz.dart';
import '../../../../config/database/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/supplier_repository.dart';

class DeleteSupplierUseCase extends ParamsUseCase<void, String> {
  final SupplierRepository repository;

  DeleteSupplierUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) {
    return repository.deleteSupplier(params);
  }
}
