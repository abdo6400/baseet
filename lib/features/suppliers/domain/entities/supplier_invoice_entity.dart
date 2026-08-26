import 'package:equatable/equatable.dart';

class SupplierInvoiceItemEntity extends Equatable {
  final String productName;
  final int quantity;
  final double unitPrice;

  const SupplierInvoiceItemEntity({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  double get subtotal => quantity * unitPrice;

  @override
  List<Object?> get props => [productName, quantity, unitPrice];
}

class SupplierInvoiceEntity extends Equatable {
  final String id;
  final String supplierId;
  final String supplierName;
  final DateTime date;
  final List<SupplierInvoiceItemEntity> items;
  final double totalAmount;
  final double paidAmount;
  final String? notes;

  const SupplierInvoiceEntity({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.date,
    required this.items,
    required this.totalAmount,
    this.paidAmount = 0.0,
    this.notes,
  });

  double get remainingAmount => totalAmount - paidAmount;

  @override
  List<Object?> get props => [
        id,
        supplierId,
        supplierName,
        date,
        items,
        totalAmount,
        paidAmount,
        notes,
      ];
}
