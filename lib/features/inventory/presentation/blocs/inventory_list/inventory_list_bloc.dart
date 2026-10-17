import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseet/features/catalog/domain/entities/category_entity.dart';
import 'package:baseet/features/catalog/domain/usecases/get_categories_usecase.dart';
import 'package:baseet/features/inventory/domain/usecases/get_inventory_stats_usecase.dart';
import 'package:baseet/features/inventory/domain/usecases/get_inventory_usecase.dart';
import 'package:baseet/features/inventory/presentation/blocs/inventory_list/inventory_list_event.dart';
import 'package:baseet/features/inventory/presentation/blocs/inventory_list/inventory_list_state.dart';

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
    if (statsResult.isLeft()) {
      statsResult.fold(
          (failure) => emit(state.copyWith(
              status: InventoryListStatus.error,
              errorMessage: failure.message)),
          (_) {});
      return;
    }
    final stats = statsResult.getOrElse(() => throw StateError('Unreachable'));

    final categoriesResult = await getCategoriesUseCase();
    if (categoriesResult.isLeft()) {
      categoriesResult.fold(
          (failure) => emit(state.copyWith(
              status: InventoryListStatus.error,
              errorMessage: failure.message)),
          (_) {});
      return;
    }
    final allCats = categoriesResult.fold(
      (l) => <CategoryEntity>[
        const CategoryEntity(id: 'cat_0', name: 'الكل', iconName: 'grid')
      ],
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
        totalProductsCount: stats.totalProducts,
        lowStockCount: stats.lowStockCount,
        stockValue: stats.stockValue,
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
