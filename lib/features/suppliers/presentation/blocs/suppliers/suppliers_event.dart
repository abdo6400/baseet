import 'package:equatable/equatable.dart';

abstract class SuppliersEvent extends Equatable {
  const SuppliersEvent();

  @override
  List<Object?> get props => [];
}

class LoadSuppliersEvent extends SuppliersEvent {
  final String? searchQuery;

  const LoadSuppliersEvent({this.searchQuery});

  @override
  List<Object?> get props => [searchQuery];
}

class SearchSuppliersEvent extends SuppliersEvent {
  final String query;

  const SearchSuppliersEvent(this.query);

  @override
  List<Object?> get props => [query];
}
