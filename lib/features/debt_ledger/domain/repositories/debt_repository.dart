import 'package:baseet/features/debt_ledger/domain/entities/debt_stats.dart';
import 'package:dartz/dartz.dart';
import 'package:baseet/core/error/failures.dart';
import 'package:baseet/core/enums/enums.dart';
import 'package:baseet/features/debt_ledger/domain/entities/customer_entity.dart';
import 'package:baseet/features/debt_ledger/domain/entities/debt_transaction_entity.dart';

abstract class DebtRepository {
  Future<Either<Failure, List<CustomerEntity>>> getCustomers(
      {String? searchQuery,
      DebtStatus? statusFilter,
      bool sortByHighest = false});
  Future<Either<Failure, CustomerEntity>> getCustomerById(String id);
  Future<Either<Failure, List<DebtTransactionEntity>>> getCustomerTransactions(
      String customerId);
  Future<Either<Failure, CustomerEntity>> addCustomer(CustomerEntity customer);
  Future<Either<Failure, DebtTransactionEntity>> addPaymentVoucher({
    required String customerId,
    required double amount,
    required String? notes,
    String? receiptPath,
  });
  Future<Either<Failure, DebtStats>> getDebtStats();
}
