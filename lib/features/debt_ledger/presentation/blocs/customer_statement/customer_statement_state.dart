import 'package:equatable/equatable.dart';
import 'package:baseet/features/debt_ledger/domain/entities/customer_entity.dart';
import 'package:baseet/features/debt_ledger/domain/entities/debt_transaction_entity.dart';

enum CustomerStatementStatus { initial, loading, loaded, error }

class CustomerStatementState extends Equatable {
  final CustomerStatementStatus status;
  final CustomerEntity? customer;
  final List<DebtTransactionEntity> transactions;
  final String? errorMessage;

  const CustomerStatementState({
    this.status = CustomerStatementStatus.initial,
    this.customer,
    this.transactions = const [],
    this.errorMessage,
  });

  CustomerStatementState copyWith({
    CustomerStatementStatus? status,
    CustomerEntity? customer,
    List<DebtTransactionEntity>? transactions,
    String? errorMessage,
  }) {
    return CustomerStatementState(
      status: status ?? this.status,
      customer: customer ?? this.customer,
      transactions: transactions ?? this.transactions,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, customer, transactions, errorMessage];
}
