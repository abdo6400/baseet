import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:baseet/core/error/failures.dart';
import 'package:baseet/core/usecase/usecase.dart';
import 'package:baseet/features/debt_ledger/domain/entities/debt_transaction_entity.dart';
import 'package:baseet/features/debt_ledger/domain/repositories/debt_repository.dart';

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

class AddPaymentVoucherUseCase
    extends ParamsUseCase<DebtTransactionEntity, AddPaymentVoucherParams> {
  final DebtRepository repository;

  AddPaymentVoucherUseCase(this.repository);

  @override
  Future<Either<Failure, DebtTransactionEntity>> call(
      AddPaymentVoucherParams params) {
    if (params.customerId.isEmpty ||
        !params.amount.isFinite ||
        params.amount <= 0) {
      return Future.value(
          const Left(ValidationFailure(message: 'validation.invalid_payment')));
    }
    return repository.addPaymentVoucher(
      customerId: params.customerId,
      amount: params.amount,
      notes: params.notes,
      receiptPath: params.receiptPath,
    );
  }
}
