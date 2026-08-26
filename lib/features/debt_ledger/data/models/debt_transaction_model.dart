import 'package:baseet/core/enums/enums.dart';
import 'package:baseet/features/debt_ledger/domain/entities/debt_transaction_entity.dart';

class DebtTransactionModel extends DebtTransactionEntity {
  const DebtTransactionModel({
    required super.id,
    required super.customerId,
    required super.type,
    required super.amount,
    required super.date,
    super.notes,
    required super.remainingBalance,
    super.receiptPath,
  });

  factory DebtTransactionModel.fromMap(Map<String, dynamic> map) {
    return DebtTransactionModel(
      id: map['id'] as String,
      customerId: map['customerId'] as String,
      type: TransactionType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => TransactionType.saleCredit,
      ),
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String?,
      remainingBalance: (map['remainingBalance'] as num).toDouble(),
      receiptPath: map['receiptPath'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'type': type.name,
      'amount': amount,
      'date': date.toIso8601String(),
      'notes': notes,
      'remainingBalance': remainingBalance,
      'receiptPath': receiptPath,
    };
  }

  factory DebtTransactionModel.fromEntity(DebtTransactionEntity entity) {
    return DebtTransactionModel(
      id: entity.id,
      customerId: entity.customerId,
      type: entity.type,
      amount: entity.amount,
      date: entity.date,
      notes: entity.notes,
      remainingBalance: entity.remainingBalance,
      receiptPath: entity.receiptPath,
    );
  }
}
