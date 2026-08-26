import 'package:get_it/get_it.dart';
import '../../features/reports/data/datasources/reports_local_datasource.dart';
import '../../features/reports/data/repositories/reports_repository_impl.dart';
import '../../features/reports/domain/repositories/reports_repository.dart';
import '../../features/reports/domain/usecases/get_report_summary_usecase.dart';
import '../../features/reports/presentation/blocs/reports/reports_bloc.dart';

void initReportsLocator(GetIt sl) {
  // Datasource
  sl.registerLazySingleton<ReportsLocalDataSource>(() => ReportsLocalDataSourceImpl(database: sl()));

  // Repository
  sl.registerLazySingleton<ReportsRepository>(() => ReportsRepositoryImpl(sl()));

  // UseCases
  sl.registerLazySingleton(() => GetReportSummaryUseCase(sl()));

  // BLoCs
  sl.registerFactory(() => ReportsBloc(getReportSummaryUseCase: sl()));
}
