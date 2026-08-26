import 'package:dartz/dartz.dart';
import '../../../../config/database/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/supplier_repository.dart';

class GetTotalSupplierDebtUseCase extends NoParamsUseCase<double> {
  final SupplierRepository repository;

  GetTotalSupplierDebtUseCase(this.repository);

  @override
  Future<Either<Failure, double>> call() {
    return repository.getTotalSupplierDebt();
  }
}
