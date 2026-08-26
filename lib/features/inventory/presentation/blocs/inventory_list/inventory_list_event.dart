import 'package:equatable/equatable.dart';

abstract class InventoryListEvent extends Equatable {
  const InventoryListEvent();

  @override
  List<Object?> get props => [];
}

class LoadInventoryEvent extends InventoryListEvent {
  final String? categoryId;
  final String? searchQuery;
  final bool onlyLowStock;

  const LoadInventoryEvent({
    this.categoryId,
    this.searchQuery,
    this.onlyLowStock = false,
  });

  @override
  List<Object?> get props => [categoryId, searchQuery, onlyLowStock];
}

class SelectInventoryCategoryEvent extends InventoryListEvent {
  final String categoryId;

  const SelectInventoryCategoryEvent(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class SearchInventoryEvent extends InventoryListEvent {
  final String query;

  const SearchInventoryEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class ToggleLowStockFilterEvent extends InventoryListEvent {}
