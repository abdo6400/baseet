import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../config/database/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/customer_entity.dart';
import '../repositories/debt_repository.dart';

class AddCustomerParams extends Equatable {
  final CustomerEntity customer;

  const AddCustomerParams(this.customer);

  @override
  List<Object?> get props => [customer];
}

class AddCustomerUseCase extends ParamsUseCase<CustomerEntity, AddCustomerParams> {
  final DebtRepository repository;

  AddCustomerUseCase(this.repository);

  @override
  Future<Either<Failure, CustomerEntity>> call(AddCustomerParams params) {
    return repository.addCustomer(params.customer);
  }
}
