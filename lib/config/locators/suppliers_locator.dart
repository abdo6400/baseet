import 'package:get_it/get_it.dart';
import '../../features/suppliers/data/datasources/supplier_local_datasource.dart';
import '../../features/suppliers/data/repositories/supplier_repository_impl.dart';
import '../../features/suppliers/domain/repositories/supplier_repository.dart';
import '../../features/suppliers/domain/usecases/add_supplier_invoice_usecase.dart';
import '../../features/suppliers/domain/usecases/add_supplier_usecase.dart';
import '../../features/suppliers/domain/usecases/delete_supplier_usecase.dart';
import '../../features/suppliers/domain/usecases/get_supplier_invoices_usecase.dart';
import '../../features/suppliers/domain/usecases/get_suppliers_usecase.dart';
import '../../features/suppliers/domain/usecases/get_total_supplier_debt_usecase.dart';
import '../../features/suppliers/presentation/blocs/add_supplier/add_supplier_bloc.dart';
import '../../features/suppliers/presentation/blocs/supplier_statement/supplier_statement_bloc.dart';
import '../../features/suppliers/presentation/blocs/suppliers/suppliers_bloc.dart';

void initSuppliersLocator(GetIt sl) {
  // Datasource
  sl.registerLazySingleton<SupplierLocalDataSource>(
    () => SupplierLocalDataSourceImpl(database: sl()),
  );

  // Repository
  sl.registerLazySingleton<SupplierRepository>(
    () => SupplierRepositoryImpl(sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => GetSuppliersUseCase(sl()));
  sl.registerLazySingleton(() => AddSupplierUseCase(sl()));
  sl.registerLazySingleton(() => DeleteSupplierUseCase(sl()));
  sl.registerLazySingleton(() => AddSupplierInvoiceUseCase(sl()));
  sl.registerLazySingleton(() => GetSupplierInvoicesUseCase(sl()));
  sl.registerLazySingleton(() => GetTotalSupplierDebtUseCase(sl()));

  // BLoCs
  sl.registerFactory(() => SuppliersBloc(
        getSuppliersUseCase: sl(),
        getTotalSupplierDebtUseCase: sl(),
        deleteSupplierUseCase: sl(),
      ));
  sl.registerFactory(() => AddSupplierBloc(addSupplierUseCase: sl()));
  sl.registerFactory(() => SupplierStatementBloc(
        getSupplierInvoicesUseCase: sl(),
        addSupplierInvoiceUseCase: sl(),
      ));
}
