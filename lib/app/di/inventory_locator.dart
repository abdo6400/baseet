import 'package:get_it/get_it.dart';
import 'package:baseet/features/inventory/data/datasources/inventory_local_datasource.dart';
import 'package:baseet/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:baseet/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:baseet/features/inventory/domain/usecases/add_category_usecase.dart';
import 'package:baseet/features/inventory/domain/usecases/add_product_usecase.dart';
import 'package:baseet/features/inventory/domain/usecases/get_inventory_stats_usecase.dart';
import 'package:baseet/features/inventory/domain/usecases/get_inventory_usecase.dart';
import 'package:baseet/features/inventory/presentation/blocs/add_category/add_category_bloc.dart';
import 'package:baseet/features/inventory/presentation/blocs/add_product/add_product_bloc.dart';
import 'package:baseet/features/inventory/presentation/blocs/inventory_list/inventory_list_bloc.dart';

void initInventoryLocator(GetIt sl) {
  // Datasource
  sl.registerLazySingleton<InventoryLocalDataSource>(
      () => InventoryLocalDataSourceImpl(database: sl()));

  // Repository
  sl.registerLazySingleton<InventoryRepository>(
      () => InventoryRepositoryImpl(sl()));

  // UseCases
  sl.registerLazySingleton(() => GetInventoryUseCase(sl()));

  sl.registerLazySingleton(() => AddProductUseCase(sl(), sl()));
  sl.registerLazySingleton(() => AddCategoryUseCase(sl(), sl()));
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
