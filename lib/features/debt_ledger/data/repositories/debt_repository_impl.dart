import 'package:dartz/dartz.dart';
import 'package:baseet/config/database/error/failures.dart';
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
    return Failure.handleCall(() => localDataSource.getCustomers(
          searchQuery: searchQuery,
          statusFilter: statusFilter,
          sortByHighest: sortByHighest,
        ));
  }

  @override
  Future<Either<Failure, CustomerEntity>> getCustomerById(String id) {
    return Failure.handleCall(() => localDataSource.getCustomerById(id));
  }

  @override
  Future<Either<Failure, List<DebtTransactionEntity>>> getCustomerTransactions(String customerId) {
    return Failure.handleCall(() => localDataSource.getCustomerTransactions(customerId));
  }

  @override
  Future<Either<Failure, CustomerEntity>> addCustomer(CustomerEntity customer) {
    return Failure.handleCall(() => localDataSource.addCustomer(CustomerModel.fromEntity(customer)));
  }

  @override
  Future<Either<Failure, void>> deleteCustomer(String id) {
    return Failure.handleCall(() => localDataSource.deleteCustomer(id));
  }

  @override
  Future<Either<Failure, DebtTransactionEntity>> addPaymentVoucher({
    required String customerId,
    required double amount,
    required String? notes,
    String? receiptPath,
  }) {
    return Failure.handleCall(() => localDataSource.addPaymentVoucher(
          customerId: customerId,
          amount: amount,
          notes: notes,
          receiptPath: receiptPath,
        ));
  }

  @override
  Future<Either<Failure, Map<String, double>>> getDebtStats() {
    return Failure.handleCall(() => localDataSource.getDebtStats());
  }
}
