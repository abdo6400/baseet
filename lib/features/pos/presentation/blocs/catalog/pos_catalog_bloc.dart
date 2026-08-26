import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseet/features/inventory/domain/entities/category_entity.dart';
import 'package:baseet/features/inventory/domain/usecases/get_categories_usecase.dart';
import 'package:baseet/features/pos/domain/usecases/get_pos_catalog_usecase.dart';
import 'package:baseet/features/pos/domain/usecases/get_today_sales_usecase.dart';
import 'pos_catalog_event.dart';
import 'pos_catalog_state.dart';

class PosCatalogBloc extends Bloc<PosCatalogEvent, PosCatalogState> {
  final GetPosCatalogUseCase getCatalogUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetTodaySalesUseCase getTodaySalesUseCase;

  PosCatalogBloc({
    required this.getCatalogUseCase,
    required this.getCategoriesUseCase,
    required this.getTodaySalesUseCase,
  }) : super(const PosCatalogState()) {
    on<LoadPosCatalogEvent>(_onLoadCatalog);
    on<SelectCategoryEvent>(_onSelectCategory);
    on<SearchCatalogEvent>(_onSearchCatalog);
  }

  Future<void> _onLoadCatalog(LoadPosCatalogEvent event, Emitter<PosCatalogState> emit) async {
    emit(state.copyWith(status: PosCatalogStatus.loading));

    final salesResult = await getTodaySalesUseCase();
    final double sales = salesResult.fold((l) => 0.0, (r) => r);

    final categoriesResult = await getCategoriesUseCase();
    final allCats = categoriesResult.fold(
      (l) => <CategoryEntity>[const CategoryEntity(id: 'cat_0', name: 'الكل', iconName: 'grid')],
      (cats) => [
        const CategoryEntity(id: 'cat_0', name: 'الكل', iconName: 'grid'),
        ...cats.where((c) => c.id != 'cat_0'),
      ],
    );

    final catalogResult = await getCatalogUseCase(GetPosCatalogParams(
      categoryId: event.categoryId ?? state.selectedCategoryId,
      searchQuery: event.searchQuery ?? state.searchQuery,
    ));

    catalogResult.fold(
      (failure) => emit(state.copyWith(
        status: PosCatalogStatus.error,
        errorMessage: failure.message,
      )),
      (products) => emit(state.copyWith(
        status: PosCatalogStatus.loaded,
        products: products,
        categories: allCats,
        todaySales: sales,
      )),
    );
  }

  Future<void> _onSelectCategory(SelectCategoryEvent event, Emitter<PosCatalogState> emit) async {
    emit(state.copyWith(selectedCategoryId: event.categoryId));
    add(LoadPosCatalogEvent(categoryId: event.categoryId, searchQuery: state.searchQuery));
  }

  Future<void> _onSearchCatalog(SearchCatalogEvent event, Emitter<PosCatalogState> emit) async {
    emit(state.copyWith(searchQuery: event.query));
    add(LoadPosCatalogEvent(categoryId: state.selectedCategoryId, searchQuery: event.query));
  }
}
