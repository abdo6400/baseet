import 'package:equatable/equatable.dart';
import '../../../../core/enums/enums.dart';

class DebtTransactionEntity extends Equatable {
  final String id;
  final String customerId;
  final TransactionType type;
  final double amount;
  final DateTime date;
  final String? notes;
  final double remainingBalance;
  final String? receiptPath;

  const DebtTransactionEntity({
    required this.id,
    required this.customerId,
    required this.type,
    required this.amount,
    required this.date,
    this.notes,
    required this.remainingBalance,
    this.receiptPath,
  });

  @override
  List<Object?> get props => [
        id,
        customerId,
        type,
        amount,
        date,
        notes,
        remainingBalance,
        receiptPath,
      ];
}
