import 'package:dartz/dartz.dart';
import 'package:baseet/config/database/error/failures.dart';
import 'package:baseet/core/usecase/usecase.dart';
import '../repositories/debt_repository.dart';

class DeleteCustomerUseCase extends ParamsUseCase<void, String> {
  final DebtRepository repository;

  DeleteCustomerUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) {
    return repository.deleteCustomer(params);
  }
}
