import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../config/database/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/debt_transaction_entity.dart';
import '../repositories/debt_repository.dart';

class AddPaymentVoucherParams extends Equatable {
  final String customerId;
  final double amount;
  final String? notes;
  final String? receiptPath;

  const AddPaymentVoucherParams({
    required this.customerId,
    required this.amount,
    this.notes,
    this.receiptPath,
  });

  @override
  List<Object?> get props => [customerId, amount, notes, receiptPath];
}

class AddPaymentVoucherUseCase extends ParamsUseCase<DebtTransactionEntity, AddPaymentVoucherParams> {
  final DebtRepository repository;

  AddPaymentVoucherUseCase(this.repository);

  @override
  Future<Either<Failure, DebtTransactionEntity>> call(AddPaymentVoucherParams params) {
    return repository.addPaymentVoucher(
      customerId: params.customerId,
      amount: params.amount,
      notes: params.notes,
      receiptPath: params.receiptPath,
    );
  }
}
