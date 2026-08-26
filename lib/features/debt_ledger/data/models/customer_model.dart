import 'package:baseet/core/enums/enums.dart';
import 'package:baseet/features/debt_ledger/domain/entities/customer_entity.dart';

class CustomerModel extends CustomerEntity {
  const CustomerModel({
    required super.id,
    required super.name,
    required super.phone,
    super.totalDebt = 0.0,
    super.creditLimit = 3000.0,
    super.lastPaymentDate,
    super.address,
    super.notes,
    super.status = DebtStatus.regular,
  });

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    final statusStr = map['status'] as String?;
    final status = DebtStatus.values.firstWhere(
      (s) => s.name == statusStr,
      orElse: () => DebtStatus.regular,
    );

    return CustomerModel(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      totalDebt: (map['totalDebt'] as num).toDouble(),
      creditLimit: (map['creditLimit'] as num?)?.toDouble() ?? 3000.0,
      lastPaymentDate: map['lastPaymentDate'] != null
          ? DateTime.tryParse(map['lastPaymentDate'] as String)
          : null,
      address: map['address'] as String?,
      notes: map['notes'] as String?,
      status: status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'totalDebt': totalDebt,
      'creditLimit': creditLimit,
      'lastPaymentDate': lastPaymentDate?.toIso8601String(),
      'address': address,
      'notes': notes,
      'status': status.name,
    };
  }

  factory CustomerModel.fromEntity(CustomerEntity entity) {
    return CustomerModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      totalDebt: entity.totalDebt,
      creditLimit: entity.creditLimit,
      lastPaymentDate: entity.lastPaymentDate,
      address: entity.address,
      notes: entity.notes,
      status: entity.status,
    );
  }
}
