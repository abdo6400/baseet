import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseet/features/debt_ledger/domain/usecases/get_customers_usecase.dart';
import 'package:baseet/features/debt_ledger/domain/usecases/get_debt_stats_usecase.dart';
import 'customers_list_event.dart';
import 'customers_list_state.dart';

class CustomersListBloc extends Bloc<CustomersListEvent, CustomersListState> {
  final GetCustomersUseCase getCustomersUseCase;
  final GetDebtStatsUseCase getDebtStatsUseCase;

  CustomersListBloc({
    required this.getCustomersUseCase,
    required this.getDebtStatsUseCase,
  }) : super(const CustomersListState()) {
    on<LoadCustomersListEvent>(_onLoadCustomers);
    on<SearchCustomersEvent>(_onSearchCustomers);
    on<FilterCustomersByStatusEvent>(_onFilterCustomers);
  }

  Future<void> _onLoadCustomers(
    LoadCustomersListEvent event,
    Emitter<CustomersListState> emit,
  ) async {
    emit(state.copyWith(status: CustomersListStatus.loading));

    final statsResult = await getDebtStatsUseCase();
    final stats = statsResult.fold(
      (l) => {'total': 0.0, 'overdue': 0.0, 'todayCollections': 0.0},
      (r) => r,
    );

    final customersResult = await getCustomersUseCase(GetCustomersParams(
      searchQuery: event.searchQuery ?? state.searchQuery,
      statusFilter: event.statusFilter ?? state.statusFilter,
      sortByHighest: event.sortByHighest,
    ));

    customersResult.fold(
      (failure) => emit(state.copyWith(
        status: CustomersListStatus.error,
        errorMessage: failure.message,
      )),
      (customers) => emit(state.copyWith(
        status: CustomersListStatus.loaded,
        customers: customers,
        totalDebt: stats['total'] ?? 0.0,
        overdueDebt: stats['overdue'] ?? 0.0,
        todayCollections: stats['todayCollections'] ?? 0.0,
      )),
    );
  }

  Future<void> _onSearchCustomers(
    SearchCustomersEvent event,
    Emitter<CustomersListState> emit,
  ) async {
    emit(state.copyWith(searchQuery: event.query));
    add(LoadCustomersListEvent(
      searchQuery: event.query,
      statusFilter: state.statusFilter,
      sortByHighest: state.sortByHighest,
    ));
  }

  Future<void> _onFilterCustomers(
    FilterCustomersByStatusEvent event,
    Emitter<CustomersListState> emit,
  ) async {
    emit(state.copyWith(
      statusFilter: event.status,
      sortByHighest: event.sortByHighest,
    ));
    add(LoadCustomersListEvent(
      searchQuery: state.searchQuery,
      statusFilter: event.status,
      sortByHighest: event.sortByHighest,
    ));
  }
}
