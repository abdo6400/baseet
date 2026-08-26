import 'package:equatable/equatable.dart';
import 'package:baseet/core/enums/enums.dart';
import 'package:baseet/features/pos/domain/entities/cart_item_entity.dart';

abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => [];
}

class SetPaymentMethodEvent extends CheckoutEvent {
  final PaymentMethod method;

  const SetPaymentMethodEvent(this.method);

  @override
  List<Object?> get props => [method];
}

class SelectCustomerForDebtEvent extends CheckoutEvent {
  final String customerId;
  final String customerName;

  const SelectCustomerForDebtEvent({
    required this.customerId,
    required this.customerName,
  });

  @override
  List<Object?> get props => [customerId, customerName];
}

class SetPaidAmountEvent extends CheckoutEvent {
  final double amount;

  const SetPaidAmountEvent(this.amount);

  @override
  List<Object?> get props => [amount];
}

class SubmitCheckoutEvent extends CheckoutEvent {
  final List<CartItemEntity> items;
  final double totalAmount;
  final String? notes;
  final String? receiptPath;

  const SubmitCheckoutEvent({
    required this.items,
    required this.totalAmount,
    this.notes,
    this.receiptPath,
  });

  @override
  List<Object?> get props => [items, totalAmount, notes, receiptPath];
}
