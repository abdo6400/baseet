import 'package:get_it/get_it.dart';
import 'package:baseet/features/more_settings/data/datasources/settings_local_datasource.dart';
import 'package:baseet/features/more_settings/data/repositories/settings_repository_impl.dart';
import 'package:baseet/features/more_settings/domain/repositories/settings_repository.dart';
import 'package:baseet/features/more_settings/domain/usecases/clear_data_usecase.dart';
import 'package:baseet/features/more_settings/domain/usecases/restore_demo_data_usecase.dart';
import 'package:baseet/features/more_settings/presentation/blocs/data_management/data_management_bloc.dart';

void initSettingsLocator(GetIt sl) {
  sl.registerLazySingleton(() => SettingsLocalDataSource(sl()));
  sl.registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(sl()));
  sl.registerLazySingleton(() => ClearDataUseCase(sl()));
  sl.registerLazySingleton(() => RestoreDemoDataUseCase(sl()));
  sl.registerFactory(() => DataManagementBloc(sl(), sl()));
}
