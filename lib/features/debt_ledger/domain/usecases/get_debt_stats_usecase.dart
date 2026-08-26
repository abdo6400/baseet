import 'package:dartz/dartz.dart';
import '../../../../config/database/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/debt_repository.dart';

class GetDebtStatsUseCase extends NoParamsUseCase<Map<String, double>> {
  final DebtRepository repository;

  GetDebtStatsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, double>>> call() {
    return repository.getDebtStats();
  }
}
