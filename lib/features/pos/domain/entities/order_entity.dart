import 'package:equatable/equatable.dart';
import '../../../../core/enums/enums.dart';
import 'cart_item_entity.dart';

class OrderEntity extends Equatable {
  final String id;
  final String invoiceNumber;
  final List<CartItemEntity> items;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final PaymentMethod paymentMethod;
  final String? customerId;
  final String? customerName;
  final DateTime createdAt;
  final String? notes;
  final String? receiptPath;

  const OrderEntity({
    required this.id,
    required this.invoiceNumber,
    required this.items,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.paymentMethod,
    this.customerId,
    this.customerName,
    required this.createdAt,
    this.notes,
    this.receiptPath,
  });

  @override
  List<Object?> get props => [
        id,
        invoiceNumber,
        items,
        totalAmount,
        paidAmount,
        remainingAmount,
        paymentMethod,
        customerId,
        customerName,
        createdAt,
        notes,
        receiptPath,
      ];
}
