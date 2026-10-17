import 'package:get_it/get_it.dart';
import 'package:baseet/features/reports/data/datasources/reports_local_datasource.dart';
import 'package:baseet/features/reports/data/repositories/reports_repository_impl.dart';
import 'package:baseet/features/reports/domain/repositories/reports_repository.dart';
import 'package:baseet/features/reports/domain/usecases/get_report_summary_usecase.dart';
import 'package:baseet/features/reports/presentation/blocs/reports/reports_bloc.dart';

void initReportsLocator(GetIt sl) {
  // Datasource
  sl.registerLazySingleton<ReportsLocalDataSource>(
      () => ReportsLocalDataSourceImpl(database: sl(), context: sl()));

  // Repository
  sl.registerLazySingleton<ReportsRepository>(
      () => ReportsRepositoryImpl(sl()));

  // UseCases
  sl.registerLazySingleton(() => GetReportSummaryUseCase(sl()));

  // BLoCs
  sl.registerFactory(() => ReportsBloc(getReportSummaryUseCase: sl()));
}
