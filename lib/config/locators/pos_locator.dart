import 'package:get_it/get_it.dart';
import '../../features/inventory/domain/usecases/get_categories_usecase.dart';
import '../../features/pos/data/datasources/pos_local_datasource.dart';
import '../../features/pos/data/repositories/pos_repository_impl.dart';
import '../../features/pos/domain/repositories/pos_repository.dart';
import '../../features/pos/domain/usecases/get_pos_catalog_usecase.dart';
import '../../features/pos/domain/usecases/get_today_sales_usecase.dart';
import '../../features/pos/domain/usecases/process_checkout_usecase.dart';
import '../../features/pos/presentation/blocs/cart/cart_bloc.dart';
import '../../features/pos/presentation/blocs/catalog/pos_catalog_bloc.dart';
import '../../features/pos/presentation/blocs/checkout/checkout_bloc.dart';
import '../../features/pos/presentation/blocs/receipts/pos_receipts_bloc.dart';

void initPosLocator(GetIt sl) {
  // Datasource
  sl.registerLazySingleton<PosLocalDataSource>(() => PosLocalDataSourceImpl(database: sl()));

  // Repository
  sl.registerLazySingleton<PosRepository>(() => PosRepositoryImpl(sl()));

  // UseCases
  sl.registerLazySingleton(() => GetPosCatalogUseCase(sl()));
  sl.registerLazySingleton(() => ProcessCheckoutUseCase(sl()));
  sl.registerLazySingleton(() => GetTodaySalesUseCase(sl()));

  // BLoCs
  sl.registerFactory(() => PosCatalogBloc(
        getCatalogUseCase: sl(),
        getCategoriesUseCase: sl<GetCategoriesUseCase>(),
        getTodaySalesUseCase: sl(),
      ));
  sl.registerLazySingleton(() => CartBloc());
  sl.registerFactory(() => CheckoutBloc(processCheckoutUseCase: sl()));
  sl.registerFactory(() => PosReceiptsBloc(repository: sl()));
}
