import 'package:baseet/core/services/operation_context.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:baseet/core/error/failures.dart';
import 'package:baseet/core/usecase/usecase.dart';
import 'package:baseet/features/debt_ledger/domain/entities/customer_entity.dart';
import 'package:baseet/features/debt_ledger/domain/repositories/debt_repository.dart';

class AddCustomerParams extends Equatable {
  final CustomerEntity customer;

  const AddCustomerParams(this.customer);

  @override
  List<Object?> get props => [customer];
}

class AddCustomerUseCase
    extends ParamsUseCase<CustomerEntity, AddCustomerParams> {
  final DebtRepository repository;

  final OperationContext context;
  AddCustomerUseCase(this.repository, this.context);

  @override
  Future<Either<Failure, CustomerEntity>> call(AddCustomerParams params) {
    final customer = params.customer;
    if (customer.name.trim().isEmpty ||
        !customer.totalDebt.isFinite ||
        customer.totalDebt < 0 ||
        !customer.creditLimit.isFinite ||
        customer.creditLimit < 0) {
      return Future.value(const Left(
          ValidationFailure(message: 'validation.invalid_customer')));
    }
    return repository.addCustomer(customer.copyWith(id: context.newId('cust')));
  }
}
