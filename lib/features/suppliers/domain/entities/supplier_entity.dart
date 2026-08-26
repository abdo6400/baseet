import 'package:equatable/equatable.dart';

class SupplierEntity extends Equatable {
  final String id;
  final String name;
  final String companyName;
  final String phone;
  final double totalDebt; // Outstanding amount owed to supplier
  final String? address;
  final DateTime? lastTransactionDate;

  const SupplierEntity({
    required this.id,
    required this.name,
    required this.companyName,
    required this.phone,
    this.totalDebt = 0.0,
    this.address,
    this.lastTransactionDate,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        companyName,
        phone,
        totalDebt,
        address,
        lastTransactionDate,
      ];
}
