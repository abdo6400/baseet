import 'package:equatable/equatable.dart';
import 'package:baseet/features/inventory/domain/entities/category_entity.dart';
import 'package:baseet/features/pos/domain/entities/product_entity.dart';

enum PosCatalogStatus { initial, loading, loaded, error }

class PosCatalogState extends Equatable {
  final PosCatalogStatus status;
  final List<ProductEntity> products;
  final List<CategoryEntity> categories;
  final String selectedCategoryId;
  final String searchQuery;
  final double todaySales;
  final String? errorMessage;

  const PosCatalogState({
    this.status = PosCatalogStatus.initial,
    this.products = const [],
    this.categories = const [],
    this.selectedCategoryId = 'cat_0',
    this.searchQuery = '',
    this.todaySales = 0.0,
    this.errorMessage,
  });

  PosCatalogState copyWith({
    PosCatalogStatus? status,
    List<ProductEntity>? products,
    List<CategoryEntity>? categories,
    String? selectedCategoryId,
    String? searchQuery,
    double? todaySales,
    String? errorMessage,
  }) {
    return PosCatalogState(
      status: status ?? this.status,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      todaySales: todaySales ?? this.todaySales,
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
        todaySales,
        errorMessage,
      ];
}
