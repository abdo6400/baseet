import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../config/database/error/failures.dart';
import '../../../../core/enums/enums.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/customer_entity.dart';
import '../repositories/debt_repository.dart';

class GetCustomersParams extends Equatable {
  final String? searchQuery;
  final DebtStatus? statusFilter;
  final bool sortByHighest;

  const GetCustomersParams({
    this.searchQuery,
    this.statusFilter,
    this.sortByHighest = false,
  });

  @override
  List<Object?> get props => [searchQuery, statusFilter, sortByHighest];
}

class GetCustomersUseCase extends ParamsUseCase<List<CustomerEntity>, GetCustomersParams> {
  final DebtRepository repository;

  GetCustomersUseCase(this.repository);

  @override
  Future<Either<Failure, List<CustomerEntity>>> call(GetCustomersParams params) {
    return repository.getCustomers(
      searchQuery: params.searchQuery,
      statusFilter: params.statusFilter,
      sortByHighest: params.sortByHighest,
    );
  }
}
