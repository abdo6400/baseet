import 'package:baseet/features/debt_ledger/domain/entities/debt_stats.dart';
import 'package:baseet/core/error/repository_call.dart';
import 'package:dartz/dartz.dart';
import 'package:baseet/core/error/failures.dart';
import 'package:baseet/core/enums/enums.dart';
import 'package:baseet/features/debt_ledger/data/datasources/debt_local_datasource.dart';
import 'package:baseet/features/debt_ledger/data/models/customer_model.dart';
import 'package:baseet/features/debt_ledger/domain/entities/customer_entity.dart';
import 'package:baseet/features/debt_ledger/domain/entities/debt_transaction_entity.dart';
import 'package:baseet/features/debt_ledger/domain/repositories/debt_repository.dart';

class DebtRepositoryImpl implements DebtRepository {
  final DebtLocalDataSource localDataSource;

  DebtRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<CustomerEntity>>> getCustomers({
    String? searchQuery,
    DebtStatus? statusFilter,
    bool sortByHighest = false,
  }) {
    return repositoryCall(() => localDataSource.getCustomers(
          searchQuery: searchQuery,
          statusFilter: statusFilter,
          sortByHighest: sortByHighest,
        ));
  }

  @override
  Future<Either<Failure, CustomerEntity>> getCustomerById(String id) {
    return repositoryCall(() => localDataSource.getCustomerById(id));
  }

  @override
  Future<Either<Failure, List<DebtTransactionEntity>>> getCustomerTransactions(
      String customerId) {
    return repositoryCall(
        () => localDataSource.getCustomerTransactions(customerId));
  }

  @override
  Future<Either<Failure, CustomerEntity>> addCustomer(CustomerEntity customer) {
    return repositoryCall(
        () => localDataSource.addCustomer(CustomerModel.fromEntity(customer)));
  }

  @override
  Future<Either<Failure, DebtTransactionEntity>> addPaymentVoucher({
    required String customerId,
    required double amount,
    required String? notes,
    String? receiptPath,
  }) {
    return repositoryCall(() => localDataSource.addPaymentVoucher(
          customerId: customerId,
          amount: amount,
          notes: notes,
          receiptPath: receiptPath,
        ));
  }

  @override
  Future<Either<Failure, DebtStats>> getDebtStats() {
    return repositoryCall(() => localDataSource.getDebtStats());
  }
}
