import 'package:equatable/equatable.dart';
import 'package:baseet/features/debt_ledger/domain/entities/customer_entity.dart';
import 'package:baseet/features/debt_ledger/domain/entities/debt_transaction_entity.dart';

enum PaymentVoucherStatus { initial, submitting, success, error }

class PaymentVoucherState extends Equatable {
  final PaymentVoucherStatus status;
  final CustomerEntity? selectedCustomer;
  final double amount;
  final DebtTransactionEntity? completedTransaction;
  final String? errorMessage;

  const PaymentVoucherState({
    this.status = PaymentVoucherStatus.initial,
    this.selectedCustomer,
    this.amount = 0.0,
    this.completedTransaction,
    this.errorMessage,
  });

  double get remainingDebtAfterPayment =>
      selectedCustomer != null ? (selectedCustomer!.totalDebt - amount).clamp(0.0, 999999.0) : 0.0;

  PaymentVoucherState copyWith({
    PaymentVoucherStatus? status,
    CustomerEntity? selectedCustomer,
    double? amount,
    DebtTransactionEntity? completedTransaction,
    String? errorMessage,
  }) {
    return PaymentVoucherState(
      status: status ?? this.status,
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
      amount: amount ?? this.amount,
      completedTransaction: completedTransaction ?? this.completedTransaction,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedCustomer,
        amount,
        completedTransaction,
        errorMessage,
      ];
}
