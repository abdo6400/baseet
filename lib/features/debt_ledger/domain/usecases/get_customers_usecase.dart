import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:baseet/core/error/failures.dart';
import 'package:baseet/core/enums/enums.dart';
import 'package:baseet/core/usecase/usecase.dart';
import 'package:baseet/features/debt_ledger/domain/entities/customer_entity.dart';
import 'package:baseet/features/debt_ledger/domain/repositories/debt_repository.dart';

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

class GetCustomersUseCase
    extends ParamsUseCase<List<CustomerEntity>, GetCustomersParams> {
  final DebtRepository repository;

  GetCustomersUseCase(this.repository);

  @override
  Future<Either<Failure, List<CustomerEntity>>> call(
      GetCustomersParams params) {
    return repository.getCustomers(
      searchQuery: params.searchQuery,
      statusFilter: params.statusFilter,
      sortByHighest: params.sortByHighest,
    );
  }
}
