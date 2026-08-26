import 'package:equatable/equatable.dart';

abstract class PaymentVoucherEvent extends Equatable {
  const PaymentVoucherEvent();

  @override
  List<Object?> get props => [];
}

class SelectVoucherCustomerEvent extends PaymentVoucherEvent {
  final String customerId;

  const SelectVoucherCustomerEvent(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class SetVoucherAmountEvent extends PaymentVoucherEvent {
  final double amount;

  const SetVoucherAmountEvent(this.amount);

  @override
  List<Object?> get props => [amount];
}

class SubmitPaymentVoucherEvent extends PaymentVoucherEvent {
  final String customerId;
  final double amount;
  final String? notes;
  final String? receiptPath;

  const SubmitPaymentVoucherEvent({
    required this.customerId,
    required this.amount,
    this.notes,
    this.receiptPath,
  });

  @override
  List<Object?> get props => [customerId, amount, notes, receiptPath];
}
