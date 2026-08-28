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

  OrderEntity copyWith({
    String? id,
    String? invoiceNumber,
    List<CartItemEntity>? items,
    double? totalAmount,
    double? paidAmount,
    double? remainingAmount,
    PaymentMethod? paymentMethod,
    String? customerId,
    String? customerName,
    DateTime? createdAt,
    String? notes,
    String? receiptPath,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      receiptPath: receiptPath ?? this.receiptPath,
    );
  }

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
