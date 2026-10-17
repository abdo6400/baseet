import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:baseet/core/error/failures.dart';
import 'package:baseet/core/usecase/usecase.dart';
import 'package:baseet/features/debt_ledger/domain/entities/customer_entity.dart';
import 'package:baseet/features/debt_ledger/domain/entities/debt_transaction_entity.dart';
import 'package:baseet/features/debt_ledger/domain/repositories/debt_repository.dart';

class GetCustomerStatementParams extends Equatable {
  final String customerId;

  const GetCustomerStatementParams(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class CustomerStatementResult extends Equatable {
  final CustomerEntity customer;
  final List<DebtTransactionEntity> transactions;

  const CustomerStatementResult({
    required this.customer,
    required this.transactions,
  });

  @override
  List<Object?> get props => [customer, transactions];
}

class GetCustomerStatementUseCase
    extends ParamsUseCase<CustomerStatementResult, GetCustomerStatementParams> {
  final DebtRepository repository;

  GetCustomerStatementUseCase(this.repository);

  @override
  Future<Either<Failure, CustomerStatementResult>> call(
      GetCustomerStatementParams params) async {
    final customerResult = await repository.getCustomerById(params.customerId);
    return customerResult.fold(
      (failure) => Left(failure),
      (customer) async {
        final txResult =
            await repository.getCustomerTransactions(params.customerId);
        return txResult.fold(
          (txFailure) => Left(txFailure),
          (transactions) => Right(CustomerStatementResult(
            customer: customer,
            transactions: transactions,
          )),
        );
      },
    );
  }
}
