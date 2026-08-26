import 'package:get_it/get_it.dart';
import '../../features/inventory/data/datasources/inventory_local_datasource.dart';
import '../../features/inventory/data/repositories/inventory_repository_impl.dart';
import '../../features/inventory/domain/repositories/inventory_repository.dart';
import '../../features/inventory/domain/usecases/add_category_usecase.dart';
import '../../features/inventory/domain/usecases/add_product_usecase.dart';
import '../../features/inventory/domain/usecases/get_categories_usecase.dart';
import '../../features/inventory/domain/usecases/get_inventory_stats_usecase.dart';
import '../../features/inventory/domain/usecases/get_inventory_usecase.dart';
import '../../features/inventory/presentation/blocs/add_category/add_category_bloc.dart';
import '../../features/inventory/presentation/blocs/add_product/add_product_bloc.dart';
import '../../features/inventory/presentation/blocs/inventory_list/inventory_list_bloc.dart';

void initInventoryLocator(GetIt sl) {
  // Datasource
  sl.registerLazySingleton<InventoryLocalDataSource>(() => InventoryLocalDataSourceImpl(database: sl()));

  // Repository
  sl.registerLazySingleton<InventoryRepository>(() => InventoryRepositoryImpl(sl()));

  // UseCases
  sl.registerLazySingleton(() => GetInventoryUseCase(sl()));
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => AddProductUseCase(sl()));
  sl.registerLazySingleton(() => AddCategoryUseCase(sl()));
  sl.registerLazySingleton(() => GetInventoryStatsUseCase(sl()));

  // BLoCs
  sl.registerFactory(() => InventoryListBloc(
        getInventoryUseCase: sl(),
        getCategoriesUseCase: sl(),
        getInventoryStatsUseCase: sl(),
      ));
  sl.registerFactory(() => AddProductBloc(addProductUseCase: sl()));
  sl.registerFactory(() => AddCategoryBloc(addCategoryUseCase: sl()));
}
