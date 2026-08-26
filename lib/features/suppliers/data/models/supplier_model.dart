import '../../domain/entities/supplier_entity.dart';

class SupplierModel extends SupplierEntity {
  const SupplierModel({
    required super.id,
    required super.name,
    required super.companyName,
    required super.phone,
    super.totalDebt = 0.0,
    super.address,
    super.lastTransactionDate,
  });

  factory SupplierModel.fromMap(Map<String, dynamic> map) {
    return SupplierModel(
      id: map['id'] as String,
      name: map['name'] as String,
      companyName: map['companyName'] as String,
      phone: map['phone'] as String,
      totalDebt: (map['totalDebt'] as num?)?.toDouble() ?? 0.0,
      address: map['address'] as String?,
      lastTransactionDate: map['lastTransactionDate'] != null
          ? DateTime.tryParse(map['lastTransactionDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'companyName': companyName,
      'phone': phone,
      'totalDebt': totalDebt,
      'address': address,
      'lastTransactionDate': lastTransactionDate?.toIso8601String(),
    };
  }

  factory SupplierModel.fromEntity(SupplierEntity entity) {
    return SupplierModel(
      id: entity.id,
      name: entity.name,
      companyName: entity.companyName,
      phone: entity.phone,
      totalDebt: entity.totalDebt,
      address: entity.address,
      lastTransactionDate: entity.lastTransactionDate,
    );
  }
}
