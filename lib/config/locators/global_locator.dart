import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baseet/config/database/local/app_database.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/debt_reminder_service.dart';
import '../../core/services/device_id_service.dart';
import '../../core/services/license_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/theme/theme_bloc/theme_bloc.dart';
import '../../features/activation/presentation/cubit/activation_cubit.dart';
import '../routes/route_config.dart';

final GetIt sl = GetIt.instance;

Future<void> initGlobalLocator(GetIt sl) async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Settings Service
  sl.registerLazySingleton<SettingsService>(() => SettingsService(sl()));

  // SQLite Database
  final appDb = AppDatabase();
  await appDb.init(seedIfEmpty: false);
  sl.registerLazySingleton<AppDatabase>(() => appDb);

  // Device ID Service
  sl.registerLazySingleton<DeviceIdService>(() => DeviceIdService(sl()));

  // License Service
  sl.registerLazySingleton<LicenseService>(() => LicenseService(sl(), sl()));

  // Debt Reminder Service
  sl.registerLazySingleton<DebtReminderService>(() => DebtReminderService(database: sl()));

  // Backup Service
  sl.registerLazySingleton<BackupService>(() => BackupService(database: sl(), settingsService: sl()));

  // Activation Cubit
  sl.registerFactory<ActivationCubit>(
    () => ActivationCubit(
      deviceIdService: sl(),
      licenseService: sl(),
      appDatabase: sl(),
    ),
  );

  // Router
  sl.registerLazySingleton<AppRouter>(() => AppRouter());

  // ThemeBloc
  sl.registerLazySingleton<ThemeBloc>(() => ThemeBloc(sl()));
}
