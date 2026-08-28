import 'package:equatable/equatable.dart';
import 'package:baseet/core/enums/enums.dart';
import 'package:baseet/features/debt_ledger/domain/entities/customer_entity.dart';

enum CustomersListStatus { initial, loading, loaded, error }

class CustomersListState extends Equatable {
  final CustomersListStatus status;
  final List<CustomerEntity> customers;
  final String searchQuery;
  final DebtStatus? statusFilter;
  final bool sortByHighest;
  final double totalDebt;
  final double overdueDebt;
  final double todayCollections;
  final String? errorMessage;

  const CustomersListState({
    this.status = CustomersListStatus.initial,
    this.customers = const [],
    this.searchQuery = '',
    this.statusFilter,
    this.sortByHighest = false,
    this.totalDebt = 0.0,
    this.overdueDebt = 0.0,
    this.todayCollections = 0.0,
    this.errorMessage,
  });

  CustomersListState copyWith({
    CustomersListStatus? status,
    List<CustomerEntity>? customers,
    String? searchQuery,
    DebtStatus? statusFilter,
    bool? sortByHighest,
    double? totalDebt,
    double? overdueDebt,
    double? todayCollections,
    String? errorMessage,
  }) {
    return CustomersListState(
      status: status ?? this.status,
      customers: customers ?? this.customers,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter,
      sortByHighest: sortByHighest ?? this.sortByHighest,
      totalDebt: totalDebt ?? this.totalDebt,
      overdueDebt: overdueDebt ?? this.overdueDebt,
      todayCollections: todayCollections ?? this.todayCollections,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        customers,
        searchQuery,
        statusFilter,
        sortByHighest,
        totalDebt,
        overdueDebt,
        todayCollections,
        errorMessage,
      ];
}
