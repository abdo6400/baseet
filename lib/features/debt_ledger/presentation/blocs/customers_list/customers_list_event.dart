import 'package:equatable/equatable.dart';
import 'package:baseet/core/enums/enums.dart';

abstract class CustomersListEvent extends Equatable {
  const CustomersListEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomersListEvent extends CustomersListEvent {
  final String? searchQuery;
  final DebtStatus? statusFilter;
  final bool sortByHighest;

  const LoadCustomersListEvent({
    this.searchQuery,
    this.statusFilter,
    this.sortByHighest = false,
  });

  @override
  List<Object?> get props => [searchQuery, statusFilter, sortByHighest];
}

class SearchCustomersEvent extends CustomersListEvent {
  final String query;

  const SearchCustomersEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterCustomersByStatusEvent extends CustomersListEvent {
  final DebtStatus? status;
  final bool sortByHighest;

  const FilterCustomersByStatusEvent({this.status, this.sortByHighest = false});

  @override
  List<Object?> get props => [status, sortByHighest];
}
