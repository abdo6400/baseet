import 'package:baseet/core/enums/enums.dart';
import 'package:baseet/features/pos/domain/entities/cart_item_entity.dart';
import 'package:baseet/features/pos/domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.invoiceNumber,
    required super.items,
    required super.totalAmount,
    required super.paidAmount,
    required super.remainingAmount,
    required super.paymentMethod,
    super.customerId,
    super.customerName,
    required super.createdAt,
    super.notes,
    super.receiptPath,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, List<CartItemEntity> items) {
    return OrderModel(
      id: map['id'] as String,
      invoiceNumber: map['invoiceNumber'] as String,
      items: items,
      totalAmount: (map['totalAmount'] as num).toDouble(),
      paidAmount: (map['paidAmount'] as num).toDouble(),
      remainingAmount: (map['remainingAmount'] as num).toDouble(),
      paymentMethod: PaymentMethod.values.firstWhere(
        (p) => p.name == map['paymentMethod'],
        orElse: () => PaymentMethod.cash,
      ),
      customerId: map['customerId'] as String?,
      customerName: map['customerName'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      notes: map['notes'] as String?,
      receiptPath: map['receiptPath'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'remainingAmount': remainingAmount,
      'paymentMethod': paymentMethod.name,
      'customerId': customerId,
      'customerName': customerName,
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
      'receiptPath': receiptPath,
    };
  }

  factory OrderModel.fromEntity(OrderEntity entity) {
    return OrderModel(
      id: entity.id,
      invoiceNumber: entity.invoiceNumber,
      items: entity.items,
      totalAmount: entity.totalAmount,
      paidAmount: entity.paidAmount,
      remainingAmount: entity.remainingAmount,
      paymentMethod: entity.paymentMethod,
      customerId: entity.customerId,
      customerName: entity.customerName,
      createdAt: entity.createdAt,
      notes: entity.notes,
      receiptPath: entity.receiptPath,
    );
  }
}
