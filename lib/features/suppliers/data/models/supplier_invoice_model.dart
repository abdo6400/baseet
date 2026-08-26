import '../../domain/entities/supplier_invoice_entity.dart';

class SupplierInvoiceItemModel extends SupplierInvoiceItemEntity {
  const SupplierInvoiceItemModel({
    required super.productName,
    required super.quantity,
    required super.unitPrice,
  });

  factory SupplierInvoiceItemModel.fromMap(Map<String, dynamic> map) {
    return SupplierInvoiceItemModel(
      productName: map['productName'] as String,
      quantity: (map['quantity'] as num).toInt(),
      unitPrice: (map['unitPrice'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap(String invoiceId, int index) {
    return {
      'id': 'sii_${invoiceId}_$index',
      'invoiceId': invoiceId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'subtotal': subtotal,
    };
  }

  factory SupplierInvoiceItemModel.fromEntity(SupplierInvoiceItemEntity entity) {
    return SupplierInvoiceItemModel(
      productName: entity.productName,
      quantity: entity.quantity,
      unitPrice: entity.unitPrice,
    );
  }
}

class SupplierInvoiceModel extends SupplierInvoiceEntity {
  const SupplierInvoiceModel({
    required super.id,
    required super.supplierId,
    required super.supplierName,
    required super.date,
    required super.items,
    required super.totalAmount,
    super.paidAmount = 0.0,
    super.notes,
  });

  factory SupplierInvoiceModel.fromMap(
    Map<String, dynamic> map,
    List<SupplierInvoiceItemModel> items,
  ) {
    return SupplierInvoiceModel(
      id: map['id'] as String,
      supplierId: map['supplierId'] as String,
      supplierName: map['supplierName'] as String,
      date: DateTime.parse(map['date'] as String),
      items: items,
      totalAmount: (map['totalAmount'] as num).toDouble(),
      paidAmount: (map['paidAmount'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'date': date.toIso8601String(),
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'remainingAmount': remainingAmount,
      'notes': notes,
    };
  }

  factory SupplierInvoiceModel.fromEntity(SupplierInvoiceEntity entity) {
    return SupplierInvoiceModel(
      id: entity.id,
      supplierId: entity.supplierId,
      supplierName: entity.supplierName,
      date: entity.date,
      items: entity.items
          .map((i) => SupplierInvoiceItemModel.fromEntity(i))
          .toList(),
      totalAmount: entity.totalAmount,
      paidAmount: entity.paidAmount,
      notes: entity.notes,
    );
  }
}
