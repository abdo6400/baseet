import 'package:get_it/get_it.dart';
import 'business_locator.dart';
import 'package:baseet/features/catalog/data/datasources/catalog_local_datasource.dart';
import 'package:baseet/app/di/settings_locator.dart';
import 'package:baseet/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:baseet/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:baseet/features/catalog/domain/usecases/get_categories_usecase.dart';
import 'package:baseet/app/di/debt_locator.dart';
import 'package:baseet/app/di/global_locator.dart';
import 'package:baseet/app/di/inventory_locator.dart';
import 'package:baseet/app/di/pos_locator.dart';
import 'package:baseet/app/di/reports_locator.dart';

Future<void> initLocator() async {
  final sl = GetIt.instance;
  await initGlobalLocator(sl);
  sl.registerLazySingleton(() => CatalogLocalDataSource(sl()));
  sl.registerLazySingleton<CatalogRepository>(
      () => CatalogRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  initPosLocator(sl);
  initDebtLocator(sl);
  initInventoryLocator(sl);
  initReportsLocator(sl);
  initSettingsLocator(sl);
  await initBusinessLocator(sl);
}
