import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../config/database/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/pos_repository.dart';

class ProcessCheckoutParams extends Equatable {
  final OrderEntity order;

  const ProcessCheckoutParams(this.order);

  @override
  List<Object?> get props => [order];
}

class ProcessCheckoutUseCase extends ParamsUseCase<OrderEntity, ProcessCheckoutParams> {
  final PosRepository repository;

  ProcessCheckoutUseCase(this.repository);

  @override
  Future<Either<Failure, OrderEntity>> call(ProcessCheckoutParams params) {
    return repository.checkout(params.order);
  }
}
