import 'package:equatable/equatable.dart';
import 'package:baseet/features/inventory/domain/entities/category_entity.dart';
import 'package:baseet/features/pos/domain/entities/product_entity.dart';

enum InventoryListStatus { initial, loading, loaded, error }

class InventoryListState extends Equatable {
  final InventoryListStatus status;
  final List<ProductEntity> products;
  final List<CategoryEntity> categories;
  final String selectedCategoryId;
  final String searchQuery;
  final bool onlyLowStock;
  final int totalProductsCount;
  final int lowStockCount;
  final double stockValue;
  final String? errorMessage;

  const InventoryListState({
    this.status = InventoryListStatus.initial,
    this.products = const [],
    this.categories = const [],
    this.selectedCategoryId = 'cat_0',
    this.searchQuery = '',
    this.onlyLowStock = false,
    this.totalProductsCount = 0,
    this.lowStockCount = 0,
    this.stockValue = 0.0,
    this.errorMessage,
  });

  InventoryListState copyWith({
    InventoryListStatus? status,
    List<ProductEntity>? products,
    List<CategoryEntity>? categories,
    String? selectedCategoryId,
    String? searchQuery,
    bool? onlyLowStock,
    int? totalProductsCount,
    int? lowStockCount,
    double? stockValue,
    String? errorMessage,
  }) {
    return InventoryListState(
      status: status ?? this.status,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      onlyLowStock: onlyLowStock ?? this.onlyLowStock,
      totalProductsCount: totalProductsCount ?? this.totalProductsCount,
      lowStockCount: lowStockCount ?? this.lowStockCount,
      stockValue: stockValue ?? this.stockValue,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        products,
        categories,
        selectedCategoryId,
        searchQuery,
        onlyLowStock,
        totalProductsCount,
        lowStockCount,
        stockValue,
        errorMessage,
      ];
}
