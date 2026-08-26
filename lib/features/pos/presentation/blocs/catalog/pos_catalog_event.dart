import 'package:equatable/equatable.dart';

abstract class PosCatalogEvent extends Equatable {
  const PosCatalogEvent();

  @override
  List<Object?> get props => [];
}

class LoadPosCatalogEvent extends PosCatalogEvent {
  final String? categoryId;
  final String? searchQuery;

  const LoadPosCatalogEvent({this.categoryId, this.searchQuery});

  @override
  List<Object?> get props => [categoryId, searchQuery];
}

class SelectCategoryEvent extends PosCatalogEvent {
  final String categoryId;

  const SelectCategoryEvent(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class SearchCatalogEvent extends PosCatalogEvent {
  final String query;

  const SearchCatalogEvent(this.query);

  @override
  List<Object?> get props => [query];
}
