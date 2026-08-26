import 'package:equatable/equatable.dart';
import '../../../../core/enums/enums.dart';

class CustomerEntity extends Equatable {
  final String id;
  final String name;
  final String phone;
  final double totalDebt;
  final double creditLimit;
  final DebtStatus status;
  final DateTime? lastPaymentDate;
  final String? address;
  final String? notes;

  const CustomerEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.totalDebt,
    this.creditLimit = 3000.0,
    this.status = DebtStatus.regular,
    this.lastPaymentDate,
    this.address,
    this.notes,
  });

  bool get isOverdue => status == DebtStatus.overdue;
  bool get isLimitExceeded => totalDebt > creditLimit;
  double get limitUsagePercent => creditLimit > 0 ? (totalDebt / creditLimit).clamp(0.0, 1.0) : 0.0;

  CustomerEntity copyWith({
    String? id,
    String? name,
    String? phone,
    double? totalDebt,
    double? creditLimit,
    DebtStatus? status,
    DateTime? lastPaymentDate,
    String? address,
    String? notes,
  }) {
    return CustomerEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      totalDebt: totalDebt ?? this.totalDebt,
      creditLimit: creditLimit ?? this.creditLimit,
      status: status ?? this.status,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      address: address ?? this.address,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        totalDebt,
        creditLimit,
        status,
        lastPaymentDate,
        address,
        notes,
      ];
}
