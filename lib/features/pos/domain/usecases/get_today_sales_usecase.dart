import 'package:dartz/dartz.dart';
import 'package:baseet/core/error/failures.dart';
import 'package:baseet/core/usecase/usecase.dart';
import 'package:baseet/features/pos/domain/repositories/pos_repository.dart';

class GetTodaySalesUseCase extends NoParamsUseCase<double> {
  final PosRepository repository;

  GetTodaySalesUseCase(this.repository);

  @override
  Future<Either<Failure, double>> call() {
    return repository.getTodaySalesTotal();
  }
}
