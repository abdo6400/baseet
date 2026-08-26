import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseet/features/inventory/domain/entities/category_entity.dart';
import 'package:baseet/features/inventory/domain/usecases/get_categories_usecase.dart';
import 'package:baseet/features/inventory/domain/usecases/get_inventory_stats_usecase.dart';
import 'package:baseet/features/inventory/domain/usecases/get_inventory_usecase.dart';
import 'inventory_list_event.dart';
import 'inventory_list_state.dart';

class InventoryListBloc extends Bloc<InventoryListEvent, InventoryListState> {
  final GetInventoryUseCase getInventoryUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetInventoryStatsUseCase getInventoryStatsUseCase;

  InventoryListBloc({
    required this.getInventoryUseCase,
    required this.getCategoriesUseCase,
    required this.getInventoryStatsUseCase,
  }) : super(const InventoryListState()) {
    on<LoadInventoryEvent>(_onLoadInventory);
    on<SelectInventoryCategoryEvent>(_onSelectCategory);
    on<SearchInventoryEvent>(_onSearch);
    on<ToggleLowStockFilterEvent>(_onToggleLowStock);
  }

  Future<void> _onLoadInventory(
    LoadInventoryEvent event,
    Emitter<InventoryListState> emit,
  ) async {
    emit(state.copyWith(status: InventoryListStatus.loading));

    final statsResult = await getInventoryStatsUseCase();
    final stats = statsResult.fold(
      (l) => {'totalProducts': 0, 'lowStockCount': 0, 'stockValue': 0.0},
      (r) => r,
    );

    final categoriesResult = await getCategoriesUseCase();
    final allCats = categoriesResult.fold(
      (l) => <CategoryEntity>[const CategoryEntity(id: 'cat_0', name: 'الكل', iconName: 'grid')],
      (cats) => [
        const CategoryEntity(id: 'cat_0', name: 'الكل', iconName: 'grid'),
        ...cats.where((c) => c.id != 'cat_0'),
      ],
    );

    final result = await getInventoryUseCase(GetInventoryParams(
      categoryId: event.categoryId ?? state.selectedCategoryId,
      searchQuery: event.searchQuery ?? state.searchQuery,
      onlyLowStock: event.onlyLowStock,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: InventoryListStatus.error,
        errorMessage: failure.message,
      )),
      (products) => emit(state.copyWith(
        status: InventoryListStatus.loaded,
        products: products,
        categories: allCats,
        totalProductsCount: stats['totalProducts'] as int? ?? 0,
        lowStockCount: stats['lowStockCount'] as int? ?? 0,
        stockValue: (stats['stockValue'] as num?)?.toDouble() ?? 0.0,
      )),
    );
  }

  Future<void> _onSelectCategory(
    SelectInventoryCategoryEvent event,
    Emitter<InventoryListState> emit,
  ) async {
    emit(state.copyWith(selectedCategoryId: event.categoryId));
    add(LoadInventoryEvent(
      categoryId: event.categoryId,
      searchQuery: state.searchQuery,
      onlyLowStock: state.onlyLowStock,
    ));
  }

  Future<void> _onSearch(
    SearchInventoryEvent event,
    Emitter<InventoryListState> emit,
  ) async {
    emit(state.copyWith(searchQuery: event.query));
    add(LoadInventoryEvent(
      categoryId: state.selectedCategoryId,
      searchQuery: event.query,
      onlyLowStock: state.onlyLowStock,
    ));
  }

  Future<void> _onToggleLowStock(
    ToggleLowStockFilterEvent event,
    Emitter<InventoryListState> emit,
  ) async {
    final next = !state.onlyLowStock;
    emit(state.copyWith(onlyLowStock: next));
    add(LoadInventoryEvent(
      categoryId: state.selectedCategoryId,
      searchQuery: state.searchQuery,
      onlyLowStock: next,
    ));
  }
}
