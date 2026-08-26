import 'package:dartz/dartz.dart';
import '../../../../config/database/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/pos_repository.dart';

class GetTodaySalesUseCase extends NoParamsUseCase<double> {
  final PosRepository repository;

  GetTodaySalesUseCase(this.repository);

  @override
  Future<Either<Failure, double>> call() {
    return repository.getTodaySalesTotal();
  }
}
