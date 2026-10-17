import 'package:baseet/features/debt_ledger/domain/entities/debt_stats.dart';
import 'package:dartz/dartz.dart';
import 'package:baseet/core/error/failures.dart';
import 'package:baseet/core/usecase/usecase.dart';
import 'package:baseet/features/debt_ledger/domain/repositories/debt_repository.dart';

class GetDebtStatsUseCase extends NoParamsUseCase<DebtStats> {
  final DebtRepository repository;

  GetDebtStatsUseCase(this.repository);

  @override
  Future<Either<Failure, DebtStats>> call() {
    return repository.getDebtStats();
  }
}
