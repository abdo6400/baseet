import 'package:dartz/dartz.dart';
import '../../../../config/database/error/failures.dart';
import '../../../../core/enums/enums.dart';
import '../entities/customer_entity.dart';
import '../entities/debt_transaction_entity.dart';

abstract class DebtRepository {
  Future<Either<Failure, List<CustomerEntity>>> getCustomers({String? searchQuery, DebtStatus? statusFilter, bool sortByHighest = false});
  Future<Either<Failure, CustomerEntity>> getCustomerById(String id);
  Future<Either<Failure, List<DebtTransactionEntity>>> getCustomerTransactions(String customerId);
  Future<Either<Failure, CustomerEntity>> addCustomer(CustomerEntity customer);
  Future<Either<Failure, void>> deleteCustomer(String id);
  Future<Either<Failure, DebtTransactionEntity>> addPaymentVoucher({
    required String customerId,
    required double amount,
    required String? notes,
    String? receiptPath,
  });
  Future<Either<Failure, Map<String, double>>> getDebtStats();
}
