import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../config/database/error/failures.dart';

abstract class ParamsUseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

abstract class NoParamsUseCase<T> {
  Future<Either<Failure, T>> call();
}

class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
