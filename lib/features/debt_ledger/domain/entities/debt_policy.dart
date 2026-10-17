import 'package:baseet/core/utils/money.dart';
import 'package:dartz/dartz.dart';
import 'package:baseet/core/error/failures.dart';

abstract class DebtPolicy {
  static Either<Failure, double> receivePayment(double debt, double amount) {
    if (!debt.isFinite ||
        debt < 0 ||
        debt > 1000000000000 ||
        !amount.isFinite ||
        amount <= 0 ||
        amount > 1000000000000 ||
        Money.cents(amount) <= 0 ||
        Money.cents(amount) > Money.cents(debt)) {
      return const Left(
          ValidationFailure(message: 'validation.invalid_payment'));
    }
    return Right((Money.cents(debt) - Money.cents(amount)) / 100);
  }

  static Either<Failure, double> addCredit(
      double debt, double amount, double creditLimit) {
    if (!debt.isFinite ||
        debt < 0 ||
        debt > 1000000000000 ||
        !amount.isFinite ||
        amount < 0 ||
        amount > 1000000000000 ||
        !creditLimit.isFinite ||
        creditLimit < 0 ||
        creditLimit > 1000000000000 ||
        Money.cents(debt) + Money.cents(amount) > Money.cents(creditLimit)) {
      return const Left(ValidationFailure(message: 'validation.credit_limit'));
    }
    return Right((Money.cents(debt) + Money.cents(amount)) / 100);
  }
}
