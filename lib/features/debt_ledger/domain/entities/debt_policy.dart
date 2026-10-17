import 'package:dartz/dartz.dart';
import 'package:baseet/core/error/failures.dart';

abstract class DebtPolicy {
  static Either<Failure, double> receivePayment(double debt, double amount) {
    if (!amount.isFinite || amount <= 0 || amount > debt) {
      return const Left(
          ValidationFailure(message: 'validation.invalid_payment'));
    }
    return Right(debt - amount);
  }

  static Either<Failure, double> addCredit(
      double debt, double amount, double creditLimit) {
    if (!amount.isFinite || amount < 0 || debt + amount > creditLimit) {
      return const Left(ValidationFailure(message: 'validation.credit_limit'));
    }
    return Right(debt + amount);
  }
}
