import 'package:get_it/get_it.dart';
import '../../features/debt_ledger/data/datasources/debt_local_datasource.dart';
import '../../features/debt_ledger/data/repositories/debt_repository_impl.dart';
import '../../features/debt_ledger/domain/repositories/debt_repository.dart';
import '../../features/debt_ledger/domain/usecases/add_customer_usecase.dart';
import '../../features/debt_ledger/domain/usecases/add_payment_voucher_usecase.dart';
import '../../features/debt_ledger/domain/usecases/delete_customer_usecase.dart';
import '../../features/debt_ledger/domain/usecases/get_customer_statement_usecase.dart';
import '../../features/debt_ledger/domain/usecases/get_customers_usecase.dart';
import '../../features/debt_ledger/domain/usecases/get_debt_stats_usecase.dart';
import '../../features/debt_ledger/presentation/blocs/add_customer/add_customer_bloc.dart';
import '../../features/debt_ledger/presentation/blocs/customer_statement/customer_statement_bloc.dart';
import '../../features/debt_ledger/presentation/blocs/customers_list/customers_list_bloc.dart';
import '../../features/debt_ledger/presentation/blocs/payment_voucher/payment_voucher_bloc.dart';

void initDebtLocator(GetIt sl) {
  // Datasource
  sl.registerLazySingleton<DebtLocalDataSource>(() => DebtLocalDataSourceImpl(database: sl()));

  // Repository
  sl.registerLazySingleton<DebtRepository>(() => DebtRepositoryImpl(sl()));

  // UseCases
  sl.registerLazySingleton(() => GetCustomersUseCase(sl()));
  sl.registerLazySingleton(() => GetCustomerStatementUseCase(sl()));
  sl.registerLazySingleton(() => AddCustomerUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCustomerUseCase(sl()));
  sl.registerLazySingleton(() => AddPaymentVoucherUseCase(sl()));
  sl.registerLazySingleton(() => GetDebtStatsUseCase(sl()));

  // BLoCs
  sl.registerFactory(() => CustomersListBloc(
        getCustomersUseCase: sl(),
        getDebtStatsUseCase: sl(),
        deleteCustomerUseCase: sl(),
      ));
  sl.registerFactory(() => CustomerStatementBloc(getCustomerStatementUseCase: sl()));
  sl.registerFactory(() => AddCustomerBloc(addCustomerUseCase: sl()));
  sl.registerFactory(() => PaymentVoucherBloc(
        addPaymentVoucherUseCase: sl(),
        getCustomersUseCase: sl(),
      ));
}
