import 'package:equatable/equatable.dart';
import 'package:baseet/core/enums/enums.dart';
import 'package:baseet/features/pos/domain/entities/order_entity.dart';

enum CheckoutStatus { initial, submitting, success, error }

class CheckoutState extends Equatable {
  final CheckoutStatus status;
  final PaymentMethod paymentMethod;
  final String? customerId;
  final String? customerName;
  final double paidAmount;
  final OrderEntity? completedOrder;
  final String? errorMessage;

  const CheckoutState({
    this.status = CheckoutStatus.initial,
    this.paymentMethod = PaymentMethod.cash,
    this.customerId,
    this.customerName,
    this.paidAmount = 0.0,
    this.completedOrder,
    this.errorMessage,
  });

  CheckoutState copyWith({
    CheckoutStatus? status,
    PaymentMethod? paymentMethod,
    String? customerId,
    String? customerName,
    double? paidAmount,
    OrderEntity? completedOrder,
    String? errorMessage,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      paidAmount: paidAmount ?? this.paidAmount,
      completedOrder: completedOrder ?? this.completedOrder,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        paymentMethod,
        customerId,
        customerName,
        paidAmount,
        completedOrder,
        errorMessage,
      ];
}
